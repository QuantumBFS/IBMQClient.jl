using IBMQClient
using Test

token = "d7339130578f8cc442dfcf260bee4049dfa25c6aabfd5ab771a693ec5cad1895f61f74f8aab7035c8ffddb83948ca17acef123c9955d9a554e02592eea5f6238"

api = IBMQClient.AuthAPI()
response = IBMQClient.login(api, token)
access_token = response["id"]
user_info = IBMQClient.user_info(api, access_token)

service = IBMQClient.ServiceAPI(user_info["urls"]["http"])
user_hubs = IBMQClient.hubs(service, access_token)
user_hubs = IBMQClient.user_hubs(service, access_token)

project = IBMQClient.ProjectAPI(service.endpoint, user_hubs[1].hub, user_hubs[1].group, user_hubs[1].project)
devices = IBMQClient.devices(project, access_token)

devices[1]
IBMQClient.IBMQDevice(devices[1])

devices[2]
devices[2]["gates"]