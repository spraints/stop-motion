#!/usr/bin/env ruby

class Fragment
  def initialize dir, prev
    @dir = dir
    @prev = prev
    prev.succ = self if prev
  end

  attr_accessor :dir, :succ

  def inspect
    if succ
      "#{duration}:[#{start} .. #{stop}]"
    else
      "#{duration}:[#{start}]"
    end
  end

  def start
    min, sec, frac = @dir[0..7].split('.').map{|x|x.to_i}
    min * 60.0 + sec + frac / 100.0
  end

  def stop
    succ && succ.start
  end

  def duration
    succ ? (stop - start) : 0.0
  end

  def images
    Dir[@dir + '/*.jpg']
  end

  def method_missing m, *a
    if a.size == 0 && m.to_s.end_with?('?')
      set? m.to_s.chop.upcase
    else
      super
    end
  end

  def set? option
    File.exist?(File.join(@dir, option))
  end

  def ffmpeg_command
    return nil if images.none?
    frame_rate =
      if normal? || loop?
        10
      elsif slow?
        3
      else
        [(images.size / duration), 1.0].max.to_i
      end
    opts = []
    if loop?
      opts << %W(-loop_input -vframes #{1 + (frame_rate * duration).to_i})
    end
    opts << %W(-r #{frame_rate} -i %03d.jpg)
    ['ffmpeg', '-y', opts, "../out/#{dir}.mp4"].flatten
  end
end

dirs = Dir['0*'].sort
fragments = []
dirs.inject(nil) { |prev, dir| Fragment.new(dir, prev).tap { |f| fragments << f } }

if ARGV.any?
  fragments = fragments.select { |f| ARGV.include? f.dir }
end

Dir.mkdir 'out' unless Dir.exist? 'out'
fragments.each do |fragment|
  cmd = fragment.ffmpeg_command
  if cmd
    Dir.chdir fragment.dir do
      puts cmd.join(' ')
      system *cmd
    end
  end
end
