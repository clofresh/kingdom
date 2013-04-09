def name()
    "kingdom"
end

def versioned_name()
    "#{name}-#{version}"
end

def version()
    %x[cat #{Rake.original_dir}/VERSION].strip
end

def builddir()
    "build"
end

def lovefile()
    "#{versioned_name}.love"
end

def distdir(dist)
    "#{builddir}/#{dist.to_s}"
end

def lovedir(os)
    if os == :osx
        "#{distdir os}/love.app"
    elsif os == :win
        "#{distdir os}/love-0.8.0-win-x86"
    else
        raise "Unknown os: #{os.inspect}"
    end
end

def appfile()
    "#{versioned_name}.app"
end

def exefile()
    "#{versioned_name}.exe"
end

def love_url(os)
    if os == :osx
        "https://bitbucket.org/rude/love/downloads/love-0.8.0-macosx-ub.zip"
    elsif os == :win
        "https://bitbucket.org/rude/love/downloads/love-0.8.0-win-x86.zip"
    else
        raise "Unknown os: #{os.inspect}"
    end
end

def upload(filename)
    require 'cloudfiles'
    require 'creds'

    cf = CloudFiles::Connection.new(:username => RACKSPACE_USER,
                                    :api_key  => RACKSPACE_API_KEY)
    container = cf.container('games')
    object = container.create_object File.basename(filename), false
    object.load_from_filename filename
    puts "Published #{filename} to #{object.public_url}"
    object
end
