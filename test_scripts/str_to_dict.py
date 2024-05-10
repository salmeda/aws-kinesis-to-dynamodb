string_dict = '{"sensorId": 8, "s_timestamp": "2024-05-10T13:23:11+01:00",\
                "currentTemperature": 132, "status": "WARN"}'

clean_str = string_dict.replace('{','').replace('}','').replace('\'','')

print(clean_str)

dictionary = {}

for pair in clean_str.split(','):
    key, value = pair.split('": ')
    dictionary[key] = value

print(dictionary["sensorId"])


print(dictionary) 
