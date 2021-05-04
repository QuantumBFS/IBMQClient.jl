using Faker

first_name = Faker.first_name()
last_name = Faker.last_name()
email = Faker.email()
token = randstring(80)
userId = randstring(80)
datetime = Faker.date_time("yyyy-mm-ddTHH:MM:SSZ")
access_token = randstring(80)
job_id = randstring(80)

response = Dict{String, Any}()

response["login"] = Dict{String, Any}(
    "userId" => userId,
    "id" => access_token,
    "created" => datetime,
    "ttl" => 123456,
)

response["user_info"] = Dict{String, Any}(
    "subscriptions" => Dict{String, Any}(
        "surveys" => 1,
        "newsletter" => 0,
        "updates" => 0,
        "tips" => 0,
        "updatesInTool" => 1
    ),
    "needsRefill" => false,
    "username" => email,
    "readOnly" => false,
    "iqxPreferences" => Dict{String, Any}(
        "hideGettingStarted" => false,
        "showChallengeAnnouncement4Anniversary" => true,
        "showGettingStartedDocs" => false,
        "showInspectorWalkthrough" => true,
        "lastComposerVersionVisited" => "v0.0.0",
        "composerLayout" => Dict{String, Any}(
            "theme" => "white",
            "showWhatsNewModal" => false,
            "simulatorSeed" => 4137,
            "composer" => Dict{String, Any}(
                "visible" => true,
                "toolbarCollapsed" => false,
                "showPhaseDisk" => true
            ),
            "visualizations" => Any[
                Dict{String, Any}(
                    "type" => "histogram"
                ),
                Dict{String, Any}(
                    "type" => "qsphere"
                )
            ],
            "code" => Dict{String, Any}(
                "visible" => true,
                "alignment" => "right",
                "code" => "qasm",
                "size" => 20
            ),
            "resource" => Dict{String, Any}(
                "visible" => true,
                "code" => "qasm",
                "type" => "documentation"
            )
        ),
        "showYourBackendsExplanation" => true
    ),
    "urls" => Dict{String, Any}(
        "services" => Dict{String, Any}(
            "extractorsService" => "https://api.quantum-computing.ibm.com/cqc",
            "quantumLab" => "https://notebooks.quantum-computing.ibm.com",
            "runtime" => "https://runtime-us-east.quantum-computing.ibm.com"
        ),
        "http" => "https://api-qcon.quantum-computing.ibm.com/api",
        "ws" => "wss://wss.quantum-computing.ibm.com/"
    ),
    "id" => "5ddc5f2f6b72bd00113d2722",
    "email" => email,
    "applications" => Any["lab", "composer", "reservations"],
    "loginAccounts" => Any[
        Dict{String, Any}("provider" => "google"),
        Dict{String, Any}("provider" => "ibmid")
    ],
    "firstName" => first_name,
    "lastName" => last_name,
    "ibmQNetwork" => true,
    "userType" => "Standard",
    "qNetworkRoles" => Any[
        "group-admin", "project-collaborator"
    ],
    "roles" => Any[],
    "emailVerified" => true,
    "terms" => Dict{String, Any}(
        "accepted" => true
    ),
    "canScheduleBackends" => true,
    "institution" => "Perimeter Quantum Intelligence Lab",
    "servicesRoles" => Any["extractorservice"]
)

response["hubs"] = Any[
    Dict{String,Any}(
        "groups" => Dict{String,Any}(
            "independent-8" => Dict{String,Any}(
                "name" => "independent-8",
                "projects" => Dict{String,Any}(
                    "main" => Dict{String,Any}(
                        "devices" => Dict{String,Any}(
                            "5f47cc94f9150a001a079449" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_casablanca",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "modes" => Dict{String,Any}(
                                        "dedicated" =>
                                            Dict{String,Any}(
                                                "minTimeSlot" => 15,
                                                "maxTimeToBook" => 180,
                                                "maxTimeSlot" => 180,
                                            ),
                                    ),
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 900,
                                                    "maxShots" => 8192,
                                                    "openPulse" => true,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "60103afaca625b70a5b1694c" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_quito",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 75,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "60427c0cfd7d013b65e51e2d" =>
                                Dict{String,Any}(
                                    "name" => "simulator_stabilizer",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 300,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "5ba502d0986f16003ea56c87" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_16_melbourne",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 75,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "5e7ca123ef0935c3e8d138b7" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_athens",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 75,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "60103adeca625b70a5b16948" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_belem",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 75,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "5ae875670f020500393162da" =>
                                Dict{String,Any}(
                                    "name" => "ibmqx2",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 75,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "60427bc8fd7d013b65e51e2c" =>
                                Dict{String,Any}(
                                    "name" => "simulator_extended_stabilizer",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 300,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "5edb5a5e44afa23d6ed14290" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_santiago",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 75,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "60103abcca625b70a5b16943" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_lima",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 75,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "5ae875670f020500393162ad" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_qasm_simulator",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 300,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "5edb5a7044afa23d6ed14294" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_bogota",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "modes" => Dict{String,Any}(
                                        "dedicated" =>
                                            Dict{String,Any}(
                                                "minTimeSlot" => 15,
                                                "maxTimeToBook" => 180,
                                                "maxTimeSlot" => 180,
                                            ),
                                    ),
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 900,
                                                    "maxShots" => 8192,
                                                    "openPulse" => true,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "60427b82fd7d013b65e51e2b" =>
                                Dict{String,Any}(
                                    "name" => "simulator_mps",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 300,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "60427b19fd7d013b65e51e2a" =>
                                Dict{String,Any}(
                                    "name" => "simulator_statevector",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 300,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "5e7ca34def0935c3e8e37460" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_rome",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "modes" => Dict{String,Any}(
                                        "dedicated" =>
                                            Dict{String,Any}(
                                                "minTimeSlot" => 15,
                                                "maxTimeToBook" => 180,
                                                "maxTimeSlot" => 180,
                                            ),
                                    ),
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 900,
                                                    "maxShots" => 8192,
                                                    "openPulse" => true,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                            "5db85d4c079e5f1b2117b303" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_armonk",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}(
                                                    "maxExperiments" => 75,
                                                    "openPulse" => true,
                                                    "maxShots" => 8192,
                                                ),
                                            "limit" => -1,
                                        ),
                                ),
                        ),
                        "name" => "main",
                        "users" => Dict{String,Any}(
                            "5ddc5f2f6b72bd00113d2722" =>
                                Dict{String,Any}(
                                    "dateJoined" => datetime,
                                    "name" => "$first_name $last_name",
                                    "deleted" => false,
                                    "email" => email,
                                ),
                        ),
                        "title" => "main",
                    ),
                ),
                "title" => "independent-8",
            ),
        ),
        "name" => "ibm-q-research",
        "isDefault" => false,
        "id" => "5d5ae38e39c23d00191cad15",
        "private" => false,
        "description" =>
            "Open access to support the quantum computing research community with more resources than the general public.",
        "class" => "Community",
        "deleted" => false,
        "licenseNotRequired" => false,
        "analytics" => true,
        "title" => "IBM Quantum Research",
        "creationDate" => "2019-08-19T17:59:42.532Z",
    ),
    Dict{String,Any}(
        "groups" => Dict{String,Any}(
            "open" => Dict{String,Any}(
                "name" => "open",
                "isDefault" => true,
                "deleted" => false,
                "title" => "open",
                "projects" => Dict{String,Any}(
                    "main" => Dict{String,Any}(
                        "devices" => Dict{String,Any}(
                            "60103afaca625b70a5b1694c" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_quito",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => false),
                                            "limit" => -1,
                                        ),
                                ),
                            "60427c0cfd7d013b65e51e2d" =>
                                Dict{String,Any}(
                                    "name" => "simulator_stabilizer",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => false),
                                            "limit" => -1,
                                        ),
                                ),
                            "60103adeca625b70a5b16948" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_belem",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => false),
                                            "limit" => -1,
                                        ),
                                ),
                            "5ba502d0986f16003ea56c87" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_16_melbourne",
                                    "priority" => 1,
                                    "deleted" => false,
                                ),
                            "5e7ca123ef0935c3e8d138b7" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_athens",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => false),
                                            "limit" => -1,
                                        ),
                                ),
                            "5ae875670f020500393162da" =>
                                Dict{String,Any}(
                                    "name" => "ibmqx2",
                                    "priority" => 1,
                                    "deleted" => false,
                                ),
                            "60427bc8fd7d013b65e51e2c" =>
                                Dict{String,Any}(
                                    "name" => "simulator_extended_stabilizer",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => false),
                                            "limit" => -1,
                                        ),
                                ),
                            "5edb5a5e44afa23d6ed14290" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_santiago",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => false),
                                            "limit" => -1,
                                        ),
                                ),
                            "60103abcca625b70a5b16943" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_lima",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => false),
                                            "limit" => -1,
                                        ),
                                ),
                            "5ae875670f020500393162ad" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_qasm_simulator",
                                    "priority" => 1,
                                    "deleted" => false,
                                ),
                            "60427b82fd7d013b65e51e2b" =>
                                Dict{String,Any}(
                                    "name" => "simulator_mps",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => false),
                                            "limit" => -1,
                                        ),
                                ),
                            "60427b19fd7d013b65e51e2a" =>
                                Dict{String,Any}(
                                    "name" => "simulator_statevector",
                                    "priority" => 1,
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => false),
                                            "limit" => -1,
                                        ),
                                ),
                            "5db85d4c079e5f1b2117b303" =>
                                Dict{String,Any}(
                                    "name" => "ibmq_armonk",
                                    "priority" => 1,
                                    "specificConfiguration" =>
                                        Dict{String,Any}("open_pulse" => true),
                                    "deleted" => false,
                                    "configuration" =>
                                        Dict{String,Any}(
                                            "capabilities" =>
                                                Dict{String,Any}("openPulse" => true),
                                        ),
                                ),
                        ),
                        "name" => "main",
                        "isDefault" => true,
                        "deleted" => false,
                        "title" => "main",
                        "description" => "",
                        "creationDate" => "2019-05-05T00:28:49.312Z",
                    ),
                ),
                "description" => "",
                "creationDate" => "2019-05-05T00:28:30.040Z",
            ),
        ),
        "ownerId" => "5b27a47e8551ba667d96c787",
        "name" => "ibm-q",
        "priority" => 1,
        "isDefault" => true,
        "device" => Any["ibmqx4", "ibmqx2", "ibmq_qasm_simulator"],
        "id" => "5cce18331b339b17b4734f98",
        "private" => false,
        "description" =>
            "Open access quantum systems. Jobs sent to these systems are processed in the United States.",
        "class" => "Open",
        "deleted" => false,
        "licenseNotRequired" => false,
        "analytics" => false,
        "title" => "IBM Quantum",
        "creationDate" => "2019-05-05T00:28:10.601Z",
    ),
]

response["devices"] = Any[
    Dict{String, Any}("local" => false, "credits_required" => true, "backend_name" => "ibmq_16_melbourne", "dynamic_reprate_enabled" => false, "multi_meas_enabled" => true, "online_date" => "2018-11-06T05:00:00Z", "quantum_volume" => 8, "gates" => Any[Dict{String, Any}("name" => "id", "parameters" => Any[], "qasm_def" => "gate id q { U(0, 0, 0) q; }", "coupling_map" => Any[Any[0], Any[1], Any[2], Any[3], Any[4], Any[5], Any[6], Any[7], Any[8], Any[9], Any[10], Any[11], Any[12], Any[13], Any[14]]), Dict{String, Any}("name" => "rz", "parameters" => Any["theta"], "qasm_def" => "gate rz(theta) q { U(0, 0, theta) q; }", "coupling_map" => Any[Any[0], Any[1], Any[2], Any[3], Any[4], Any[5], Any[6], Any[7], Any[8], Any[9], Any[10], Any[11], Any[12], Any[13], Any[14]]), Dict{String, Any}("name" => "sx", "parameters" => Any[], "qasm_def" => "gate sx q { U(pi/2, 3*pi/2, pi/2) q; }", "coupling_map" => Any[Any[0], Any[1], Any[2], Any[3], Any[4], Any[5], Any[6], Any[7], Any[8], Any[9], Any[10], Any[11], Any[12], Any[13], Any[14]]), Dict{String, Any}("name" => "x", "parameters" => Any[], "qasm_def" => "gate x q { U(pi, 0, pi) q; }", "coupling_map" => Any[Any[0], Any[1], Any[2], Any[3], Any[4], Any[5], Any[6], Any[7], Any[8], Any[9], Any[10], Any[11], Any[12], Any[13], Any[14]]), Dict{String, Any}("name" => "cx", "parameters" => Any[], "qasm_def" => "gate cx q0, q1 { CX q0, q1; }", "coupling_map" => Any[Any[0, 1], Any[0, 14], Any[1, 0], Any[1, 2], Any[1, 13], Any[2, 1], Any[2, 3], Any[2, 12], Any[3, 2], Any[3, 4], Any[3, 11], Any[4, 3], Any[4, 5], Any[4, 10], Any[5, 4], Any[5, 6], Any[5, 9], Any[6, 5], Any[6, 8], Any[7, 8], Any[8, 6], Any[8, 7], Any[8, 9], Any[9, 5], Any[9, 8], Any[9, 10], Any[10, 4], Any[10, 9], Any[10, 11], Any[11, 3], Any[11, 10], Any[11, 12], Any[12, 2], Any[12, 11], Any[12, 13], Any[13, 1], Any[13, 12], Any[13, 14], Any[14, 0], Any[14, 13]])], "sample_name" => "family: Canary, revision: 1.1", "dt" => 0.2222222222222222, "memory" => true, "processor_type" => Dict{String, Any}("family" => "Canary", "revision" => 1.1), "allow_object_storage" => true, "description" => "15 qubit device", "basis_gates" => Any["id", "rz", "sx", "x", "cx"], "backend_version" => "2.3.19", "conditional" => false, "n_registers" => 1, "coupling_map" => Any[Any[0, 1], Any[0, 14], Any[1, 0], Any[1, 2], Any[1, 13], Any[2, 1], Any[2, 3], Any[2, 12], Any[3, 2], Any[3, 4], Any[3, 11], Any[4, 3], Any[4, 5], Any[4, 10], Any[5, 4], Any[5, 6], Any[5, 9], Any[6, 5], Any[6, 8], Any[7, 8], Any[8, 6], Any[8, 7], Any[8, 9], Any[9, 5], Any[9, 8], Any[9, 10], Any[10, 4], Any[10, 9], Any[10, 11], Any[11, 3], Any[11, 10], Any[11, 12], Any[12, 2], Any[12, 11], Any[12, 13], Any[13, 1], Any[13, 12], Any[13, 14], Any[14, 0], Any[14, 13]], "meas_map" => Any[Any[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]], "url" => "None", "n_qubits" => 15, "allow_q_object" => true, "max_shots" => 8192, "open_pulse" => false, "max_experiments" => 75, "simulator" => false, "dtm" => 0.2222222222222222, "supported_instructions" => Any["cx", "id", "delay", "measure", "rz", "sx", "u1", "u2", "u3", "x"]),
    Dict{String, Any}("quantum_volume" => 1, "online_date" => "2019-10-16T04:00:00Z", "u_channel_lo" => Any[], "gates" => Any[Dict{String, Any}("name" => "id", "parameters" => Any[], "qasm_def" => "gate id q { U(0, 0, 0) q; }", "coupling_map" => Any[Any[0]]), Dict{String, Any}("name" => "rz", "parameters" => Any["theta"], "qasm_def" => "gate rz(theta) q { U(0, 0, theta) q; }", "coupling_map" => Any[Any[0]]), Dict{String, Any}("name" => "sx", "parameters" => Any[], "qasm_def" => "gate sx q { U(pi/2, 3*pi/2, pi/2) q; }", "coupling_map" => Any[Any[0]]), Dict{String, Any}("name" => "x", "parameters" => Any[], "qasm_def" => "gate x q { U(pi, 0, pi) q; }", "coupling_map" => Any[Any[0]])], "sample_name" => "family: Canary, revision: 1.2", "acquisition_latency" => Any[], "channels" => Dict{String, Any}("acquire0" => Dict{String, Any}("purpose" => "acquire", "operates" => Dict{String, Any}("qubits" => Any[0]), "type" => "acquire"), "d0" => Dict{String, Any}("purpose" => "drive", "operates" => Dict{String, Any}("qubits" => Any[0]), "type" => "drive"), "m0" => Dict{String, Any}("purpose" => "measure", "operates" => Dict{String, Any}("qubits" => Any[0]), "type" => "measure")), "dt" => 0.2222222222222222, "processor_type" => Dict{String, Any}("family" => "Canary", "revision" => 1.2), "uchannels_enabled" => true, "meas_kernels" => Any["hw_boxcar"], "parametric_pulses" => Any["gaussian", "gaussian_square", "drag", "constant"], "n_registers" => 1, "n_uchannels" => 0, "conditional_latency" => Any[], "qubit_channel_mapping" => Any[Any["d0", "m0"]], "max_experiments" => 75, "dynamic_reprate_enabled" => false, "meas_lo_range" => Any[Any[6.493370669, 7.493370669]], "rep_times" => Any[1000], "allow_object_storage" => true, "conditional" => false, "coupling_map" => nothing, "url" => "None", "qubit_lo_range" => Any[Any[4.471850366996982, 5.471850366996982]], "max_shots" => 8192, "simulator" => false, "local" => false, "backend_name" => "ibmq_armonk", "multi_meas_enabled" => true, "discriminators" => Any["quadratic_discriminator", "linear_discriminator"], "hamiltonian" => Dict{String, Any}("qub" => Dict{String, Any}("0" => 3), "osc" => Dict{String, Any}(), "h_latex" => "\\begin{align} \\mathcal{H}/\\hbar = & \\sum_{i=0}^{0}\\left(\\frac{\\omega_{q,i}}{2}(\\mathbb{I}-\\sigma_i^{z})+\\frac{\\Delta_{i}}{2}(O_i^2-O_i)+\\Omega_{d,i}D_i(t)\\sigma_i^{X}\\right) \\\\ \\end{align}", "description" => "Qubits are modeled as Duffing oscillators. In this case, the system includes higher energy states, i.e. not just |0> and |1>. The Pauli operators are generalized via the following set of transformations:\n\n\$(\\mathbb{I}-\\sigma_{i}^z)/2 \\rightarrow O_i \\equiv b^\\dagger_{i} b_{i}\$,\n\n\$\\sigma_{+} \\rightarrow b^\\dagger\$,\n\n\$\\sigma_{-} \\rightarrow b\$,\n\n\$\\sigma_{i}^X \\rightarrow b^\\dagger_{i} + b_{i}\$.\n\nQubits are coupled through resonator buses. The provided Hamiltonian has been projected into the zero excitation subspace of the resonator buses leading to an effective qubit-qubit flip-flop interaction. The qubit resonance frequencies in the Hamiltonian are the cavity dressed frequencies and not exactly what is returned by the backend defaults, which also includes the dressing due to the qubit-qubit interactions.\n\nQuantities are returned in angular frequencies, with units 2*pi*GHz.\n\nWARNING: Currently not all system Hamiltonian information is available to the public, missing values have been replaced with 0.\n", "vars" => Dict{String, Any}("wq0" => 31.23905717541087, "omegad0" => 0.11878831369204708, "delta0" => -2.1814775258495027), "h_str" => Any["_SUM[i,0,0,wq{i}/2*(I{i}-Z{i})]", "_SUM[i,0,0,delta{i}/2*O{i}*O{i}]", "_SUM[i,0,0,-delta{i}/2*O{i}]", "_SUM[i,0,0,omegad{i}*X{i}||D{i}]"]), "basis_gates" => Any["id", "rz", "sx", "x"], "backend_version" => "2.4.6", "meas_map" => Any[Any[0]], "n_qubits" => 1, "open_pulse" => true, "credits_required" => true, "memory" => true, "description" => "1 qubit device", "allow_q_object" => true, "meas_levels" => Any[1, 2], "dtm" => 0.2222222222222222, "supported_instructions" => Any["delay", "x", "play", "u1", "u2", "id", "rz", "measure", "u3", "shiftf", "acquire", "setf", "sx"])
]

response["jobs"] = Any[Dict{String, Any}("kind" => "q-object-external-storage", "backend" => Dict{String, Any}("name" => "ibmq_qasm_simulator", "id" => "5ae875670f020500393162ad"), "userId" => "5ddc5f2f6b72bd00113d2722", "status" => "COMPLETED", "id" => "6090446ea9b8c9479824290b", "endDate" => "2021-05-03T18:44:03.121Z", "hubInfo" => Dict{String, Any}("project" => Dict{String, Any}("name" => "main"), "hub" => Dict{String, Any}("name" => "ibm-q"), "group" => Dict{String, Any}("name" => "open")), "runMode" => "fairshare", "creationDate" => "2021-05-03T18:43:58.520Z"), Dict{String, Any}("kind" => "q-object-external-storage", "backend" => Dict{String, Any}("name" => "ibmq_qasm_simulator", "id" => "5ae875670f020500393162ad"), "userId" => "5ddc5f2f6b72bd00113d2722", "status" => "ERROR_VALIDATING_JOB", "id" => "6090421b6cb1a50366176853", "endDate" => "2021-05-03T18:34:05.277Z", "hubInfo" => Dict{String, Any}("project" => Dict{String, Any}("name" => "main"), "hub" => Dict{String, Any}("name" => "ibm-q"), "group" => Dict{String, Any}("name" => "open")), "creationDate" => "2021-05-03T18:34:03.908Z")]
