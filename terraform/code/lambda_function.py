import boto3
import base64
import json

print('Starting ...')
 

def lambda_handler(event, context):
    
    dynamodb = boto3.resource('dynamodb') 
    
    #table name 
    table = dynamodb.Table('kinesis-to-dynamodb-ddb') 
    
    print(event)
 
    for record in event['Records']:
        try:
            print(f"Processed Kinesis Event - EventID: {record['eventID']}")
            record_data = base64.b64decode(record['kinesis']['data']).decode('utf-8')

            print(f"Record Data: {record_data}")
 
            #eval will convert a string into the most convenient structure, in this case a dict
            record_data_dict = eval(record_data)
            
            print(record_data)
            print(record_data_dict)
            
            print('sensorId: '+str(record_data_dict['sensorId']))
            print('s_timestamp: '+str(record_data_dict['s_timestamp']))
            print('currentTemperature: '+str(record_data_dict['currentTemperature']))
            print('status: '+str(record_data_dict['status']))
 
            response = table.put_item( Item=record_data_dict ) 
            
        except Exception as e:
            print(f"An error occurred {e}")
            raise e
    print(f"Successfully processed {len(event['Records'])} records.")
 
    return event['Records']
    
    