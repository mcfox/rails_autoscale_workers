# ASWorkers
![ASW](app/assets/images/asw.png)
## Requirements

- PostgreSQL


#### How to run

```bash
foreman start
```

# References
Esse problema é resolvido no Heroku atraves de Add Ons de tereceiros

https://www.hirefire.io
https://elements.heroku.com/addons/rails-autoscale
https://github.com/adamlogic/rails_autoscale_agent
https://railsautoscale.com

Porem, no AWS não temos nada semelhante, porem o problema é exatamente o mesmo
Para resolver esse problema, foi criado esse aplicativop, que usa como critério 
para o autoscaling o numero de jobs retornado pelo aplicativo



# Instruções de Uso
- No seu aplicativo, criar uma url que retorna o numero de jobs numa fila
- Cadastre seu aplicativo informando as filas a serem controladas e qual url chamar para saber o numero de jobs
- Informe o auto scaling a ser controlado juntamente com um key e um secret com direito de alterar seu desired capacity
- Defina os parametros de controle: num máximo de maquinas, capcidade de processamento de uma maquina, ...
- Pronto. Aogra acompanhe a variação para garantir que seus jobs estão sendo processados


## TODO

## Novas Funcionanlidades

### Free Space Autoscaling on AWS RDS
Dont get out of space on RDS and no not pay for unused space
keep the free space on a safety minimum and increase a needed

```bash
Monitor Free Space in RDS
   if free space < [ 15%]
   increase free space to [ 20%] 

```

```bash

require 'aws-sdk-rds'  # v2: require 'aws-sdk'

rds = Aws::RDS::Resource.new(region: 'us-west-2')
      
rds.d_instances.each do |i|
  puts "Name (ID): #{i.id}"
  puts "Status   : #{i.db_instance_status}"
  puts
end

```

````bash
rails g scaffold RdsInstance name instance_id aws_access_key aws_secret min_free_space:integer desired_free_space:integer
````
