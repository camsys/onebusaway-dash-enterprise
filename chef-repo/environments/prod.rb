require 'chef/data_bag'
name "prod"
description "environment attributes/configuration for prod environment"
default_attributes({
                     "oba" => {
                       "user" => "ubuntu",
                       "home" => "/home/ubuntu",
                       "mvn" => {
                           "group_id" => "org.onebusaway",
                           "version_admin" => "1.1.15.1-cs-SNAPSHOT",
                           "version_core" => "1.1.15.1-cs-SNAPSHOT",
                           "version_app" => "1.1.15.1-cs-SNAPSHOT",
                           "version_transitime_core" => "0.0.2-SNAPSHOT",
                           "version_transitime_web" => "0.0.2-SNAPSHOT",
                           "repositories" => ["http://repo.prod.wmata.obaweb.org:8080/archiva/repository/snapshots/"]
                       },
                       "db_instance" => "db",
                       "db_master" => "db.prod.wmata.obaweb.org",
                       "db_user" => "oba",
                       "db_password" => "changemeprod",
                       "env" => "prod",
                       "base_domain" => "wmata.obaweb.org",
                       "db_instance_name" => "org_onebusaway_users",
                       "db_agency" => "gtfsrt",
                       "db_archive" => "gtfsrt",
                       "api_server" => "app.prod.wmata.obaweb.org:8080",
                       "admin_server" => "admin.prod.wmata.obaweb.org",
                       "prediction_api_server" => "gtfsrt.prod.wmata.obaweb.org",
                       "prediction_api_port" => "8080",
                       "admin_server_port" => "8080",
                       "tds" => {
                         "bundle_path" => "/var/lib/oba/bundle"
                       },
                       "webapp" => {
                         "artifact" => "onebusaway-enterprise-acta-webapp"
                       }
                     },
                       "transitime" => {
                         "dbhost" => "db.prod.wmata.obaweb.org:3306",
                         "dbtype" => "mysql",
                         "dbusername" => "transitime",
                         "dbpassword" => "transitimeprod",
                         "dbname" => "transitime",
                         "agency" => "1",
                         "api_key" => "prod3273b0",
                         "encryptionPassword" => "transitimeprod",
                         "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/443046490497/obawmata_prod",
                         "sqsKey" => "AKIAIAFMZDHCK3F55EIA",
                         "sqsSecret" => "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",
                         "snsKey" => "",
                         "snsSecret" => "",
                         "snsArn" => ""
                       },
                      "aws" => {
                        "cloudwatch_publish_key" => "AKIAIHDQDZCGSQMYJAHQ",
                        "cloudwatch_publish_secret" => "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",
                        "cloudwatch_endpoint" => "monitoring.us-east-1.amazonaws.com",
                        "alarmCriticalSns" => "arn:aws:sns:us-east-1:372394388595:OBAWMATA-Alarm-prod",
                        "alarmNonCriticalSns" => "arn:aws:sns:us-east-1:372394388595:OBAWMATA-Monitoring-prod"
                       },
                     "tomcat" => {
                       "user" => "tomcat7",
                       "group" => "tomcat7",
                       "base_version" => "7"
                     },
                     "java" => {
                       "jdk_version" => "7"
                     }
                   })