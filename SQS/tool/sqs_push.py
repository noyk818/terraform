import boto3

name = 'TestQueue'
sqs = boto3.resource('sqs')
try:
    queue = sqs.get_queue_by_name(QueueName=name)
except:
    queue = sqs.create_queue(QueueName=name)

msg_num = 3
msg_list = [{'Id' : '{}'.format(i+1), 'MessageBody' : 'msg_{}'.format(i+1)} for i in range(msg_num)]
response = queue.send_messages(Entries=msg_list)
print(response)
