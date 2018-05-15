require 'ptools'

module DownloadTestHelper
  def assert_downloaded(expected_filesize, source)
    download = Downloads::File.new(source)
    @retry_count = 0
    begin
      tempfile = download.download!
    rescue Net::OpenTimeout
      @retry_count += 1
      if @retry_count == 3
        skip "Remote connection to #{source} failed"
      else
        sleep(@retry_count ** 2)
        retry
      end
    end
    assert_equal(expected_filesize, tempfile.size, "Tested source URL: #{source}")
  end

  def assert_rewritten(expected_source, test_source)
    download = Downloads::File.new(test_source)

    rewritten_source, _, _ = download.before_download(test_source, {})
    assert_match(expected_source, rewritten_source, "Tested source URL: #{test_source}")
  end

  def assert_not_rewritten(source)
    assert_rewritten(source, source)
  end

  def check_ffmpeg
    File.which("ffmpeg") && File.which("mkvmerge")
  end
end