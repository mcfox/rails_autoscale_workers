# application = Application.create({
#                                      name: 'Application x',
#                                      aws_access_key_id: 'fake-key',
#                                      aws_secret_access_key: 'fake-key',
#                                      jobs_url: 'https://localhost:3000/fake-url-api'
#                                  })
#
# application.work_managers.create({
#                                      name: 'Work Manager Y',
#                                      aws_region: 'us-west-2',
#                                      autoscalinggroup_name: 'fake-aws-autoscaling-group',
#                                      queue_name: 'unknow',
#                                      max_workers: 30,
#                                      min_workers: 1,
#                                      minutes_to_process: 60,
#                                      jobs_per_cycle: 720,
#                                      minutes_between_cycles: 5,
#                                      active: false
#                                  })

Rake::Task['setup:admin'].invoke