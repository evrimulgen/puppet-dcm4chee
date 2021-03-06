# Class: dcm4chee::database::mysql. See README.md for documentation.
class dcm4chee::database::mysql () {

  include ::mysql::server

  ::mysql::db { $::dcm4chee::database_name:
    user     => $::dcm4chee::user,
    password => $::dcm4chee::database_owner_password,
    host     => $::dcm4chee::server_host,
    grant    => ['ALL'],
    sql      => "${::dcm4chee::dcm4chee_sql_path}/create.mysql",
    require  => Staging::Deploy[$::dcm4chee::staging::dcm4chee_archive_name],
  }
}
