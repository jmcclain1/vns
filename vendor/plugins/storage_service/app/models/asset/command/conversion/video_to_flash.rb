class Asset::Command::Conversion::VideoToFlash < Asset::Command::Conversion::Base
  attr_accessor :width, :height
  
  def initialize(width, height)
    self.width = width; self.height = height
  end

  def extension
    'flv'
  end

  def process(source, destination)
    opts = "-ofps 25 -of lavf -oac mp3lame -lameopts abr:br=64 -srate 22050 -ovc lavc -lavfopts i_certify_that_my_video_stream_does_not_use_b_frames -lavcopts vcodec=flv:keyint=50:vbitrate=400:mbd=2:mv0:trell:v4mv:cbp:last_pred=3 -vf scale=#{width}:#{height}"

    exec("/usr/bin/mencoder #{source} -o #{destination} #{opts} > /dev/null")
    exec("/usr/bin/flvtool2 -UP #{destination} > /dev/null")
  end

  def size
    AssetVersion::Size.new(width, height)
  end
  
  def fast?
    false
  end
end