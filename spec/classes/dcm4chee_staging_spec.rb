require 'spec_helper'

describe 'dcm4chee::staging', :type => :class do

  { 'mysql'      => {
                      'type_short' => 'mysql',
                      'configfile_short' => 'mysql'
                    },
    'postgresql' => {
                      'type_short' => 'psql',
                      'configfile_short' => 'postgres'
                    },
  }.each do |database_type, database|
    describe "with defaults, server_java_path set and database_type=#{database_type}" do
      let :pre_condition do
        "class {'dcm4chee':
           database_type    => #{database_type}, 
           server_java_path => '/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java',
        }"
      end

      it { is_expected.to contain_class('staging') }
      it { is_expected.to contain_file('/opt/dcm4chee/staging/')
            .with({
              'ensure' => 'directory',
              'owner'  => 'dcm4chee',
              'group'  => 'dcm4chee',
            })
      }
      it { is_expected.to contain_staging__deploy("dcm4chee-2.18.1-#{database['type_short']}.zip")
            .with({
              'source'  => "http://sourceforge.net/projects/dcm4che/files/dcm4chee/2.18.1/dcm4chee-2.18.1-#{database['type_short']}.zip/download",
              'target'  => '/opt/dcm4chee/staging/',
              'user'    => 'dcm4chee',
              'group'   => 'dcm4chee',
            })
            .that_requires('File[/opt/dcm4chee/staging/]')
      }
      it { is_expected.not_to contain_class('dcm4chee::staging::jai_imageio') }
      it { is_expected.to contain_class('dcm4chee::staging::jboss')
            .that_requires('Anchor[dcm4chee::staging::begin]')
            .that_requires('File[/opt/dcm4chee/staging/]')
            .that_comes_before('Anchor[dcm4chee::staging::end]')
      }
      it { is_expected.to contain_file('/usr/local/bin/validate_dcm4chee_jboss_installed.sh')
        .with({
          'ensure' => 'file',
          'owner'  => 'root',
          'group'  => 'root',
          'mode'   => '0755',
          'source' => 'puppet:///modules/dcm4chee/validate_dcm4chee_jboss_installed.sh',
        })
      }
      it { is_expected.to contain_exec("/opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/bin/install_jboss.sh")
        .with({
          'unless'    => "/usr/local/bin/validate_dcm4chee_jboss_installed.sh /opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/",
          'command'   => "/opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/bin/install_jboss.sh /opt/dcm4chee/staging/jboss-4.2.3.GA/",
          'cwd'       => '/opt/dcm4chee/staging/',
          'user'      => 'dcm4chee',
          'path'      => '/bin:/usr/bin:/usr/local/bin',
        })
        .that_requires("Staging::Deploy[dcm4chee-2.18.1-#{database['type_short']}.zip]")
        .that_requires('Class[dcm4chee::staging::jboss]')
        .that_requires('File[/usr/local/bin/validate_dcm4chee_jboss_installed.sh]')
      }
      it { is_expected.to contain_file("/opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/bin/run.sh")
            .with({
              'ensure'  => 'file',
              'owner'   => 'dcm4chee',
              'group'   => 'dcm4chee',
              'source'  => '/opt/dcm4chee/staging/jboss-4.2.3.GA/bin/run.sh',
            })
            .that_requires("Exec[/opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/bin/install_jboss.sh]")
      }
      it { is_expected.to contain_class('dcm4chee::staging::weasis')
            .that_requires('Anchor[dcm4chee::staging::begin]')
            .that_requires("File[/opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/bin/run.sh]")
            .that_comes_before('Anchor[dcm4chee::staging::end]')
      }
      it { is_expected.to contain_file("/opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/bin/run.conf")
            .with({
              'ensure' => 'absent',
            })
      }
      it { is_expected.to contain_file("/opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/server/default/deploy/jboss-web.deployer/server.xml")
            .with({
              'ensure' => 'absent',
            })
      }
      it { is_expected.to contain_file("/opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/server/default/deploy/pacs-#{database['configfile_short']}-ds.xml")
            .with({
              'ensure' => 'absent',
            })
      }
      it { is_expected.to contain_file("/opt/dcm4chee/staging/dcm4chee-2.18.1-#{database['type_short']}/server/default/conf/jboss-log4j.xml")
            .with({
              'ensure' => 'absent',
            })
      }
      it { is_expected.to contain_anchor('dcm4chee::staging::end') }
    end
  end

  describe 'given defaults and server = false' do
    let :pre_condition do
      "class {'dcm4chee':
        server => false,
      }"
    end

    it { is_expected.to contain_class('staging') }
    it { is_expected.to contain_file('/opt/dcm4chee/staging/')
          .with({
            'ensure' => 'directory',
            'owner'  => 'dcm4chee',
            'group'  => 'dcm4chee',
          })
    }
    it { is_expected.to contain_staging__deploy('dcm4chee-2.18.1-psql.zip')
          .with({
            'source'  => 'http://sourceforge.net/projects/dcm4che/files/dcm4chee/2.18.1/dcm4chee-2.18.1-psql.zip/download',
            'target'  => '/opt/dcm4chee/staging/',
            'user'    => 'dcm4chee',
            'group'   => 'dcm4chee',
          })
          .that_requires('File[/opt/dcm4chee/staging/]')
    }
    it { is_expected.not_to contain_class('dcm4chee::staging::jai_imageio') }
    it { is_expected.not_to contain_class('dcm4chee::staging::jboss') }
    it { is_expected.not_to contain_exec('/opt/dcm4chee/staging/dcm4chee-2.18.1-psql/bin/install_jboss.sh') }
    it { is_expected.not_to contain_file('/opt/dcm4chee/staging/dcm4chee-2.18.1-psql/bin/run.sh') }
    it { is_expected.not_to contain_class('dcm4chee::staging::weasis') }
  end

  describe 'given defaults, server_java_path set and weasis = false' do
    let :pre_condition do
      "class {'dcm4chee':
        server_java_path => '/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java',
        weasis           => false,
      }"
    end

    it { is_expected.to contain_class('staging') }
    it { is_expected.to contain_file('/opt/dcm4chee/staging/')
          .with({
            'ensure' => 'directory',
            'owner'  => 'dcm4chee',
            'group'  => 'dcm4chee',
          })
    }
    it { is_expected.to contain_staging__deploy('dcm4chee-2.18.1-psql.zip')
          .with({
            'source'  => 'http://sourceforge.net/projects/dcm4che/files/dcm4chee/2.18.1/dcm4chee-2.18.1-psql.zip/download',
            'target'  => '/opt/dcm4chee/staging/',
            'user'    => 'dcm4chee',
            'group'   => 'dcm4chee',
          })
          .that_requires('File[/opt/dcm4chee/staging/]')
    }
    it { is_expected.not_to contain_class('dcm4chee::staging::jai_imageio') }
    it { is_expected.to contain_class('dcm4chee::staging::jboss')
          .that_requires('File[/opt/dcm4chee/staging/]')
    }
    it { is_expected.to contain_exec('/opt/dcm4chee/staging/dcm4chee-2.18.1-psql/bin/install_jboss.sh')
          .that_requires('Staging::Deploy[dcm4chee-2.18.1-psql.zip]')
          .that_requires('Class[dcm4chee::staging::jboss]')
    }
    it { is_expected.to contain_file('/opt/dcm4chee/staging/dcm4chee-2.18.1-psql/bin/run.sh')
          .with({
            'ensure'  => 'file',
            'owner'   => 'dcm4chee',
            'group'   => 'dcm4chee',
            'source'  => '/opt/dcm4chee/staging/jboss-4.2.3.GA/bin/run.sh',
          })
          .that_requires('Exec[/opt/dcm4chee/staging/dcm4chee-2.18.1-psql/bin/install_jboss.sh]')
    }
    it { is_expected.not_to contain_class('dcm4chee::staging::weasis') }
  end

    describe "with defaults, server_java_path set" do
      let :pre_condition do
        "class {'dcm4chee':
           server_java_path         => '/usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java',
           server_dicom_compression => true,
        }"
      end

      it { is_expected.to contain_anchor('dcm4chee::staging::begin') }
      it { is_expected.to contain_class('dcm4chee::staging::jai_imageio')
            .that_requires('Anchor[dcm4chee::staging::begin]')
            .that_requires("Staging::Deploy[dcm4chee-2.18.1-psql.zip]")
            .that_comes_before('Anchor[dcm4chee::staging::end]')
      }
    end
end

