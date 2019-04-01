# ASWorkers
![ASW](app/assets/images/asw.png)
## Requirements

- PostgreSQL


#### How to run

```bash
foreman start
```


Functionalities

Monitor Free Space in RDS
if frees space < 20%
increase free space to 40%


require 'aws-sdk-rds'  # v2: require 'aws-sdk'

rds = Aws::RDS::Resource.new(region: 'us-west-2')
      
rds.db_instances.each do |i|
  puts "Name (ID): #{i.id}"
  puts "Status   : #{i.db_instance_status}"
  puts
end


rails g scaffold RdsInstance name instance_id aws_access_key aws_secret min_free_space:integer desired_free_space:integer