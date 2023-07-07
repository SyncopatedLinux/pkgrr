#!/usr/bin/env ruby

require 'tty-prompt'
require 'tty-logger'
require 'tty-option'
require 'fileutils'

class Builder
  include TTY::Option

  usage do
    program "builder"
    command "mount_chroot"
    desc "Mount the chroot environment"
  end

  flag :keep_chroot do
    short '-k'
    long '--keep-chroot'
    desc 'Keep chroot environment mounted if script fails'
  end

  def initialize
    @logger = TTY::Logger.new
    @prompt = TTY::Prompt.new
    @architectures = []
    @pkg_selection = []
    @chroot = "/mnt/chroots/arch"
  end

  def run
    params = parse

    select_packages
    select_architectures

    trap('INT') { handle_interrupt }
    trap('TERM') { cleanup(params[:keep_chroot]) }
    trap('EXIT') { cleanup(params[:keep_chroot]) }

    @architectures.each do |arch|
      trap('INT', 'DEFAULT')
      trap('TERM', 'DEFAULT')
      trap('EXIT', 'DEFAULT')

      mount_chroot
      create_chroot(arch)
      update_chroot(arch)
      build_packages(arch)
    end

    cleanup(params[:keep_chroot])
  end

  def select_packages
    pkgbuilds_dir = "#{Dir.home}/Workspace/pkgrr/pkgbuilds"

    if ARGV[0] == 'all'
      @pkg_selection = Dir.glob("#{pkgbuilds_dir}/*").select { |dir| File.directory?(dir) }
    elsif ARGV[0] == 'package'
      @pkg_selection = [ARGV[1]]
    else
      @pkg_selection = @prompt.multi_select("Select packages to build") do |menu|
        menu.choices Dir.glob("#{pkgbuilds_dir}/*").select { |dir| File.directory?(dir) }
      end
    end
  end

  def select_architectures
    @architectures = if ARGV[0] == 'all'
                       ['x86_64', 'x86_64_v3']
                     else
                       @prompt.multi_select("Select CPU architecture") do |menu|
                         menu.choice 'x86_64'
                         menu.choice 'x86_64_v3'
                       end
                     end
  end

  def unmount_chroot
    system("sudo umount #{@chroot}") if system("mountpoint -q #{@chroot}")
  end

  def mount_chroot
    unmount_chroot
    system("sudo mount --mkdir -t tmpfs -o defaults,size=8G tmpfs #{@chroot}")
  end

  def set_configs(arch)
    makepkg_conf = "#{Dir.home}/Workspace/pkgrr/devtools/makepkg-#{arch}.conf"
    makepkg_conf_symlink = "#{Dir.home}/.makepkg.conf"

    if File.exist?(makepkg_conf_symlink)
      File.delete(makepkg_conf_symlink)
    end

    File.symlink(makepkg_conf, makepkg_conf_symlink)
  end

  def create_chroot(arch)
    set_configs(arch)
    pacman_conf = "#{Dir.home}/Workspace/pkgrr/devtools/pacman-#{arch}.conf"
    makepkg_conf = "#{Dir.home}/.makepkg.conf"
    system("mkarchroot -C #{pacman_conf} -M #{makepkg_conf} #{@chroot}/root base-devel")
  end

  def update_chroot(arch)
    pacman_conf = "#{Dir.home}/Workspace/pkgrr/devtools/pacman-#{arch}.conf"
    makepkg_conf = "#{Dir.home}/.makepkg.conf"
    system("arch-nspawn -C #{pacman_conf} -M #{makepkg_conf} #{@chroot}/root pacman -Scc --noconfirm")
    system("arch-nspawn -C #{pacman_conf} -M #{makepkg_conf} #{@chroot}/root pacman -Sy")
  end

  def build_packages(arch)
    @pkg_selection.each do |pkg|
      pkgname = File.basename(pkg)
      pkg_dir = File.expand_path(pkg)

      Dir.chdir(pkg_dir) do
        system("makechrootpkg -n -c -r #{@chroot}")

        if $?.success?
          system("ssh -T ninjabot notify-send 'build complete for #{pkgname}-#{arch}'")
        end
      end
    end
  end

  def cleanup(keep_chroot)
    unless keep_chroot
      FileUtils.rm_f("#{Dir.home}/.makepkg.conf")
      unmount_chroot
      FileUtils.rm_rf("#{Dir.home}/Packages/sources")
      FileUtils.mkdir_p("#{Dir.home}/Packages/sources")
    end
  end
end

Builder.new.run
