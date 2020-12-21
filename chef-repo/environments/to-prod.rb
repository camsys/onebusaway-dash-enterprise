require 'chef/data_bag'
name "to-prod"
description "environment attributes/configuration for to-prod environment"
default_attributes({
                     "oba" => {
                       "user" => "ubuntu",
                       "home" => "/home/ubuntu",
                       "mvn" => {
                           "group_id" => "org.onebusaway",
                           "version_admin" => "2.0.0-cs",
                           "version_core" => "2.0.0-cs",
                           "version_app" => "2.0.0-cs",
                           "version_branded" => "2.0.0-cs",
                           "version_transitime_core" => "0.0.35",
                           "version_transitime_web" => "0.0.35",
                           "repositories" => ["http://repo.prod.wmata.obaweb.org:8080/archiva/repository/releases/"]
                       },
                       "db_instance" => "db",
                       "db_master" => "db.to-prod.wmata.obaweb.org",
                       "db_user" => "oba",
                       "db_password" => "changeme",
                       "env" => "prod",
                       "base_domain" => "wmata.obaweb.org",
                       "db_instance_name" => "org_onebusaway_users",
                       "db_agency" => "gtfsrt",
                       "db_archive" => "gtfsrt",
                       "api_server" => "app.to-prod.wmata.obaweb.org",
                       "admin_server" => "admin.to-prod.wmata.obaweb.org",
                       "prediction_api_server" => "gtfsrt.to-prod.wmata.obaweb.org",
                       "prediction_api_port" => "8080",
                       "admin_server_port" => "8080",
                       "tds" => {
                         "bundle_path" => "/var/lib/oba/bundle"
                       },
                       "webapp" => {
                         "artifact" => "onebusaway-enterprise-wmata-webapp"
                       },
                       "webapp" => {
                         "artifact" => "onebusaway-enterprise-wmata-webapp"
                       },
                       "wmata_webapp" => {
                          "artifact" => "onebusaway-enterprise-wmata-webapp"
                       },
                       "hart_webapp" => {
                          "artifact" => "onebusaway-enterprise-hart-webapp"
                       },
                       "sound_webapp" => {
                          "artifact" => "onebusaway-enterprise-sound-webapp"
                       },
                       "ses_host" => "email-smtp.us-east-1.amazonaws.com",
                       "ses_user" => "AKIAISKUXW2UHBZRHHNA",
                       "ses_password" => "AhxzNCmnlqzK8qjPwsQ41yHUbk3meOlHZvVRuoVoM7/t",
                       "ses_from" => "btss@wmata.com",
                       "mobile_require_ssl" => "true"
                     },
                       "transitime" => {
                         "dbhost" => "db.to-prod.wmata.obaweb.org:3306",
                         "dbrohost" => "db-ro.to-prod.wmata.obaweb.org:3306",
                         "dbtype" => "mysql",
                         "dbusername" => "transitime",
                         "dbpassword" => "transitimeprod",
                         "dbname" => "transitime",
                         "agency" => "1",
                         "api_key" => "prod3273b0",
                         "encryptionPassword" => "transitimeprod",
                         "sqsUrl" => "https://sqs.us-east-1.amazonaws.com/372394388595/obawmata_qa",
                         "sqsKey" => "AKIAIAFMZDHCK3F55EIA",
                         "sqsSecret" => "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",
                         "snsKey" => "",
                         "snsSecret" => "",
                         "snsArn" => "",
                         "retentionDays" => "90",
                         "xsqsUrl" => "https://sqs.us-east-1.amazonaws.com/443046490497/obawmata_prod",
                         "xsqsKey" => "AKIAIAFMZDHCK3F55EIA",
                         "xsqsSecret" => "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",
                         "xsnsKey" => "AKIAJ34CZNNFNL5G2CUA",
                         "xsnsSecret" => "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",
                         "xsnsArn" => "arn:aws:sns:us-east-1:443046490497:wmata_avl",
                         "xretentionDays" => "90"
                       },
                      "aws" => {
                        "cloudwatch_publish_key" => "AKIAIHDQDZCGSQMYJAHQ",
                        "cloudwatch_publish_secret" => "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",
                        "cloudwatch_endpoint" => "monitoring.us-east-1.amazonaws.com",
                        "alarmCriticalSns" => "arn:aws:sns:us-east-1:372394388595:OBAWMATA-Alarm-qa",
                        "alarmNonCriticalSns" => "arn:aws:sns:us-east-1:372394388595:OBAWMATA-Monitoring-qa"
                       },
                     "tomcat" => {
                       "user" => "tomcat_user",
                       "group" => "tomcat_group",
                       "base_version" => "8"
                     },
                     "java" => {
                       "jdk_version" => "8"
                     },
                     "apache" => {
                        "proxy" => {
                          "require" => "all granted"
                        }
                     }
		}
)