This is a solution to push data from a kinesis data stream to dynamoDB
THIS IS NOT FREE SO PLEASE DESTROY AS SOON AS YOU FINISH TESTING

To create the infrastructure:
$terraform apply

To destroup the infrastructure:
$terraform destroy

Note the Kinesis Data Stream receives data from the Kinesis data generator per: 

https://awslabs.github.io/amazon-kinesis-data-generator/web/help.html

Ive used the following seed to generate the data:

{
    "sensorId": {{random.number(50)}},
    "s_timestamp": "{{date.now}}",
    "currentTemperature": {{random.number(
        {
            "min":10,
            "max":150
        }
    )}},
    "status": "{{random.arrayElement(
        ["OK","FAIL","WARN"]
    )}}"
}

