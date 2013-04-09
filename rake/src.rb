directory builddir

namespace :src do
    desc 'Initialize and update the submodule dependencies'
    task :submodules do
        sh "git submodule update --init"
    end

    desc 'Compile a .love file'
    task :dist => [:submodules, builddir] do
        sh <<-EOS
            OUTPUT=#{builddir}/#{lovefile}
            rm -f $OUTPUT
            zip -r $OUTPUT * --exclude \\*.acorn #{builddir}/\\* \\*/.\\* creds.rb
        EOS
    end

    desc 'Compile and publish a .love file to the CDN'
    task :publish => [:dist] do
        upload "#{builddir}/#{lovefile}"
    end
end

desc 'Clean out the build directory'
task :clean do
    sh "rm -rf #{builddir}/*"
end
