#!/usr/bin/env ruby

require 'tty-prompt'
require 'tty-logger'
require 'tty-option'

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
  end

  def run
    params = parse

    # Create commands
    select_packages_cmd = Command.new(method(:select_packages))
    select_architectures_cmd = Command.new(method(:select_architectures))
    unmount_chroot_cmd = Command.new(method(:unmount_chroot))
    mount_chroot_cmd = Command.new(method(:mount_chroot))
    set_configs_cmd = Command.new(method(:set_configs))
    create_chroot_cmd = Command.new(method(:create_chroot))
    update_chroot_cmd = Command.new(method(:update_chroot))
    build_cmd = Command.new(method(:build))
    cleanup_cmd = Command.new(method(:cleanup))

    # Execute commands
    selected_packages = select_packages_cmd.execute
    selected_architectures = select_architectures_cmd.execute
    unmount_chroot_cmd.execute
    mount_chroot_cmd.execute
    set_configs_cmd.execute
    create_chroot_cmd.execute
    update_chroot_cmd.execute
    build_cmd.execute(selected_packages, selected_architectures)
    cleanup_cmd.execute(params[:keep_chroot])
  end

  # Define methods for each command...

  def unmount_chroot
    chroot = "/mnt/chroots/arch"
    if system("mountpoint -q #{chroot}")
      system("sudo umount #{chroot}")
    end
  end

  def mount_chroot
    chroot = "/mnt/chroots/arch"
    unmount_chroot
    system("sudo mount --mkdir -t tmpfs -o defaults,size=8G tmpfs #{chroot}")
  end

  def set_configs
    makepkg_conf = "#{Dir.home}/Workspace/syncopated/pkgrr/devtools/makepkg.conf"
    if File.symlink?("#{Dir.home}/.makepkg.conf")
      File.symlink(makepkg_conf, "#{Dir.home}/.makepkg.conf")
    else
      File.delete("#{Dir.home}/.makepkg.conf") if File.exist?("#{Dir.home}/.makepkg.conf")
      File.symlink(makepkg_conf, "#{Dir.home}/.makepkg.conf")
    end
  end

  def create_chroot
    set_configs
    chroot = "/mnt/chroots/arch"
    pacman_conf = "#{Dir.home}/Workspace/syncopated/pkgrr/devtools/pacman-#{arch}.conf"
    makepkg_conf = "#{Dir.home}/Workspace/syncopated/pkgrr/devtools/makepkg-#{arch}.conf"
    system("mkarchroot -C #{pacman_conf} -M #{makepkg_conf} #{chroot}/root base-devel")
  end


  def update_chroot
    chroot = "/mnt/chroots/arch"
    pacman_conf = "#{Dir.home}/Workspace/syncopated/pkgrr/devtools/pacman-#{arch}.conf"
    makepkg_conf = "#{Dir.home}/Workspace/syncopated/pkgrr/devtools/makepkg-#{arch}.conf"
    system("arch-nspawn -C #{pacman_conf} -M #{makepkg_conf} #{chroot}/root pacman -Scc --noconfirm")
    system("arch-nspawn -C #{pacman_conf} -M #{makepkg_conf} #{chroot}/root pacman -Sy")
  end

  def select_packages
    pkgbuilds_dir = "#{Dir.home}/Workspace/pkgrr/pkgbuilds"
    pkgbuild_dirs = Dir.glob("#{pkgbuilds_dir}/*").select do |dir|
      File.directory?(dir) && File.exist?("#{dir}/PKGBUILD")
    end
    pkg_names = pkgbuild_dirs.map { |dir| File.basename(dir) }
    @prompt.multi_select("Select packages to build", pkg_names)
  end

  def select_architectures
    architectures = ["all", "x86_64", "x86_64_v3"]
    selected_archs = @prompt.multi_select("Select CPU architecture", architectures)
    if selected_archs.include?("all")
      ["x86_64", "x86_64_v3"]
    else
      selected_archs
    end
  end


  def build(pkgname, arch)
    chroot = "/mnt/chroots/arch"
    pacman_conf = "#{Dir.home}/Workspace/syncopated/pkgrr/devtools/pacman-#{arch}.conf"
    makepkg_conf = "#{Dir.home}/Workspace/syncopated/pkgrr/devtools/makepkg-#{arch}.conf"
    system("cd #{Dir.home}/Workspace/pkgrr/pkgbuilds/#{pkgname}")
    system("makechrootpkg -n -c -r #{chroot}")
    if $?.success?
      system("ssh -T ninjabot notify-send 'build complete for #{pkgname}-#{arch}'")
    end
  end


  def cleanup(keep_chroot)
    unless keep_chroot
      File.unlink("#{Dir.home}/.makepkg.conf")
      unmount_chroot
      FileUtils.rm_rf(srcdest)
      FileUtils.mkdir_p(srcdest)
      File.unlink("#{Dir.home}/.makepkg.conf") if File.exist?("#{Dir.home}/.makepkg.conf")
    end
  end
end

class Command
  def initialize(action)
    @action = action
  end

  def execute(*args)
    @action.call(*args)
  end
end

Builder.new.run
