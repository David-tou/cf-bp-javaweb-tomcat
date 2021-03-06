#! /usr/bin/ruby
# coding: utf-8

require 'fetcher'
require 'fileutils'

class JavaPack

  attr_reader :global

  def initialize(global)
    @global = global
  end

  def compile
    # Fetcher.install_jdk(global)
    setup_profiled
  end

  def setup_profiled
    FileUtils.mkdir_p "#{global.build_path}/.profile.d"
    File.open("#{global.build_path}/.profile.d/jdk.sh", 'a') { |file| file.puts(bash_script) }
  end

  private

  #'-Xms' => '$MEMORY_LIMIT',
  def java_opts
    {
        '-Xmx' => '$MEMORY_LIMIT',
        '-Xms' => '$MEMORY_LIMIT',
        '-Djava.io.tmpdir=' => '\"$TMPDIR\"'
    }
  end

  def bash_script
    <<-BASH
#!/usr/bin/env bash
export JAVA_HOME="/home/vcap/app/.jdk"
export PATH="/home/vcap/app/.jdk/bin:$PATH"
export JAVA_OPTS=${JAVA_OPTS:-"#{java_opts.map{ |k, v| "#{k}#{v}" }.join(' ')}"}
export LANG="${LANG:-en_US.UTF-8}"

export CATALINA_OPTS="-Dsolr.solr.home=/home/vcap/app/webapps/solr_home -Dfile.encoding=UTF-8"

if [ -n "$VCAP_DEBUG_MODE" ]; then
  if [ "$VCAP_DEBUG_MODE" = "run" ]; then
    export JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=n"
  elif [ "$VCAP_DEBUG_MODE" = "suspend" ]; then
    export JAVA_OPTS="$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=$VCAP_DEBUG_PORT,server=y,suspend=y"
  fi
fi
    BASH
  end

end


