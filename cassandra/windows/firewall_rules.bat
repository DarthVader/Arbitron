netsh advfirewall firewall add rule name = SQLPort dir = in protocol = tcp action = allow localport = 1433 remoteip = localsubnet profile = DOMAIN

netsh advfirewall firewall add rule name = Cassandra9142 dir = in protocol = tcp action = allow localport = 9142 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra9042 dir = in protocol = tcp action = allow localport = 9042 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra7199 dir = in protocol = tcp action = allow localport = 7199 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra9160 dir = in protocol = tcp action = allow localport = 9160 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra7000 dir = in protocol = tcp action = allow localport = 7000 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra7001 dir = in protocol = tcp action = allow localport = 7001 remoteip = localsubnet profile = DOMAIN

netsh advfirewall firewall add rule name = Cassandra9142 dir = out protocol = tcp action = allow localport = 9142 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra9042 dir = out protocol = tcp action = allow localport = 9042 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra7199 dir = out protocol = tcp action = allow localport = 7199 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra9160 dir = out protocol = tcp action = allow localport = 9160 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra7000 dir = out protocol = tcp action = allow localport = 7000 remoteip = localsubnet profile = DOMAIN
netsh advfirewall firewall add rule name = Cassandra7001 dir = out protocol = tcp action = allow localport = 7001 remoteip = localsubnet profile = DOMAIN

netsh advfirewall firewall add rule name = Emby dir = out protocol = tcp action = allow localport = 8096 remoteip = localsubnet profile = DOMAIN, PUBLIC
netsh advfirewall firewall add rule name = Emby dir = in protocol = tcp action = allow localport = 8096 remoteip = localsubnet profile = DOMAIN, PUBLIC