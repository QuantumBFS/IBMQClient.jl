using IBMQClient
using JSON
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
response = IBMQClient.create_remote_job(project, devices[3], access_token)

storage_info = response["objectStorageInfo"]
upload_url = storage_info["uploadUrl"]
job_id = response["id"]
ex = "Dict{String, Any}(\"instructions\" => Any[Dict{String, Any}(\"name\" => \"x\", \"qubits\" => [0]), Dict{String, Any}(\"name\" => \"x\", \"qubits\" => [1]), Dict{String, Any}(\"name\" => \"ccx\", \"qubits\" => [0, 1, 2]), Dict{String, Any}(\"name\" => \"cx\", \"qubits\" => [0, 1]), Dict{String, Any}(\"name\" => \"measure\", \"memory\" => [0, 1, 2], \"qubits\" => [0, 1, 2])], \"header\" => Dict{String, Any}(\"name\" => :qobj_test, \"n_qubits\" => 3), \"config\" => Dict{String, Any}(\"memory_slots\" => 3, \"seed\" => 1, \"shots\" => 1024, \"max_credits\" => 3, \"n_qubits\" => 3))"
ex = eval(Meta.parse(ex))

qobj = IBMQClient.create_qobj(devices[3], ex)
IBMQClient.submit(project, devices[3], qobj, access_token)

job = IBMQClient.JobAPI(project, job_id)
IBMQClient.upload_url(job, access_token)
IBMQClient.retreive_job_info(job, access_token)
IBMQClient.properties(job, access_token)
IBMQClient.result_url(job, access_token)
IBMQClient.status(job, access_token)

IBMQClient.put_object_storage(job, upload_url, qobj, access_token)
response = IBMQClient.callback_upload(job, access_token)


# IBMQClient.cancel(job, access_token)
