use Mix.Config


# Remove useless new lines
config :logger, :console,
  format: "\r$time $metadata[$level] $levelpad$message\n"

# Set info logging level (optionnal)
config :logger, level: :info


# Some trusted peer IPs
# Replace with your own here and update reference below
peer_fly11 = "fc18:e736:105d:d49a:2ab5:14a2:698f:7021"
# peer_fly11 = "37.187.118.206"   # use this if you are not on CJDNS

# The contact info of the operator of this PeerDNS instance
config :peerdns, operator: %{
  "Name" => "your name or nickname here",
  "E-mail" => "your E-mail address here",
  "IRC" => "your IRC handle here", 
  # Other fields can be added as you wish
}

# The TLDs for which PeerDNS will handle naming
config :peerdns, tld: [".p2p", ".mesh", ".h", ".hype", ".y", ".ygg", ".tomesh"]

# For other TLDs, DNS requests are proxied to this DNS server
config :peerdns, outside: [
  {"127.0.0.1", 53},
  {"1.1.1.1", 53},
]

# Where to listen for DNS requests
config :peerdns, listen_dns: [
  # {"0.0.0.0", 53}   # Open DNS server on IPv4 network
  # {"::", 53}        # Open DNS server on IPv6 network

  {"127.0.0.1", 5454},  # Private DNS server on IPv4 network
  {"::1", 5454},        # Private DNS server on IPv6 network
]

# Where to listen for PeerDNS API requests
# The PeerDNS API is used by other PeerDNS instances to exchange data with us.
# Recommended: do not change this, let everyone connect.
# Access control is handled below.
config :peerdns, listen_api: [
  #{"0.0.0.0", 14123},       # Anyone through IPv4
  {"::", 14123},             # Anyone through IPv4 & IPv6 (on Linux)
]

# What hosts are allowed to use the privileged PeerDNS API
# These peers will be allowed to edit the data files and the trust list
config :peerdns, privileged_api_hosts: [
  "127.0.0.1",
  "::ffff:7f00:1",
  "::1"
]

# The sources of data for our name database
config :peerdns, sources: [
  [
    id: :my_domains,
    name: "My domains",
    description: "Use this list to enter domains you own.",
    file: "data/name_list.json",
    editable: true,
    weight: 1,
    ping_to: [{peer_fly11, 14123}],
    ping_interval: 3600*12,   # 12 hours
  ],
  [
    id: :my_modlist,
    name: "My modlist",
    description: "Use this list to propagate or block domains of other users.",
    file: "data/name_mod_list.json",
    editable: true,
    weight: 0.8,
  ],
]

# Under what conditions do we accept pings and endorse the pinged domains
config :peerdns, ping: [
  accept: true,
  max_interval: 3600*24,    # one day
  endorse_after: 3600*24*7, # one week
  weight: 0.6
]

# Lists of trusted neighbors
config :peerdns, peer_lists: [
  [
    id: :trust_list,
    name: "Trust list",
    description: "Use this list to enter peers you trust personnally. This list is saved to disk at each change and will be reloaded when PeerDNS restarts.",
    file: "data/trust_list.json",
    editable: true,
    default: [
      [name: "fly11", ip: peer_fly11, api_port: 14123, weight: 0.9]
    ]
  ],
  [
    id: :temporary_peers,
    name: "Temporary peers",
    description: "Use this list to add temporary peers. This list will be cleared whenever PeerDNS restarts.",
    editable: true
    # no file name means it is not saved
  ],
  [
    id: :yggdrasil,
    name: "Yggdrasil peers",
    description: "A temporary list of direct Yggdrasil mesh peers. Added by script.",
    editable: true
  ]
]

# Look up our CJDNS neighbors by connecting to local cjdroute and try to
# use them as neighbors
config :peerdns, cjdns_neighbors: [
  enable: true,
  update_interval: 3600,
  api_port: 14123, weight: 0.5,
]

# Allow any peer to push domains and accept them with a default very low weight
config :peerdns, open: :accept
config :peerdns, open_weight: 0.1

# Don't store domains that have weight lower than this
config :peerdns, cutoff: 0.05

# Expire entries from other peers after one day
config :peerdns, entry_expiration_time: 3600*24

# Pull regularly from our neighbors (trust list & cjdns peers)
# - every 1 hour, update entries with weight >= 0.5
# - every 12 hours, update all entries
config :peerdns, pull_policy: [
  [interval: 3600, cutoff: 0.5],
  [interval: 12*3600, cutoff: 0.05],
]

# Server for static UI assets if not present locally
config :peerdns, offsite_ui: "http://peerdns.p2pstuff.xyz/ui/"