function LoadXMLDoc_cjdns() {
  var xmlhttp = new XMLHttpRequest();
  xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
      CJDNSMap(this);
    }
  };
  xmlhttp.open("GET", "/cgi-bin/peers-cjdns", true);
  xmlhttp.send();
}

function LoadXMLDoc_ygg() {
  var xmlhttp = new XMLHttpRequest();
    xmlhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
     YggdrasilMap(this);
    }
  };
  xmlhttp.open("GET", "/cgi-bin/peers-yggdrasil", true);
  xmlhttp.send();
}

// Cleanup the json provided by the CJDNS
// Otherwise it will not parse properly
// ToDo - this is really hacking, there should be a better way of doing this
function ToJson(json) {
  json=json.replace(new RegExp("}", "g"),"\"null\": \"\"}");
  json=json.replace(new RegExp("  ","g")," ");
  json=json.replace(new RegExp("  ","g")," ");
  json=json.replace(new RegExp("\n","g")," ");
  json=json.replace("},  ]","}]");
  // Parse it
  return JSON.parse(json);
}

function CJDNSMap(ajax) {
  var Nodes;
  var NodeExist=Array();
  jsonDisplay=ajax.response.replace(new RegExp("'", "g"),"\"");
  Nodes=ToJson(jsonDisplay);
  for (var a=0; a< Nodes.peers.length; a++) {
      var parts=Nodes.peers[a].addr.split(".");
      UpdateNode(parts[5],public2IPv6(parts[5]),parts[4], Nodes.peers[a].recvKbps + "kpbs / " + Nodes.peers[a].sendKbps + " kbps","cjdns",NodeExist);
  }
  DeleteNodes("cjdns",NodeExist);
  setTimeout("LoadXMLDoc_cjdns()",1000);
}

lastrx=[];
lasttx=[];
function YggdrasilMap(ajax) {
  var Nodes;
  var NodeExist=Array();
  str=ajax.response;
  Nodes=JSON.parse(str);
  for (var i in Nodes.peers) {
      var addr=i;
      node=Nodes.peers[i];
      if (node.port>0) { //not self
          rx=node.bytes_recvd-lastrx[node.port];
          tx=node.bytes_sent-lasttx[node.port];
          lastrx[node.port]=node.bytes_recvd;
          lasttx[node.port]=node.bytes_sent;
          UpdateNode(addr,addr,node.port,rx + " bps /" + tx + " bps", "yggdrasil",NodeExist);
    }
  }
  DeleteNodes("yggdrasil",NodeExist);
  setTimeout("LoadXMLDoc_ygg()",1000);
}

// Update Map
// vis.js Initialization
var nodeIDs=[];
var edgeIDs=[];
var nodesArray=[];
var edgesArray=[];
var nodes=[];
var edges=[];
var network=[];
//var nodeIds,edgesIDs,  nodesArray, nodes, edgesArray, edges, network;

function InitMap(name) {
  nodeIDs[name]=[];
  edgeIDs[name]=[];
  nodesArray[name]=[{id: 0, label: 'Me'}];
  nodes[name] = new vis.DataSet(nodesArray[name]);
  edgesArray[name] = [];
  edges[name] = new vis.DataSet(edgesArray[name]);
  var container = document.getElementById('network' + name);
  var data = {
      nodes: nodes[name],
      edges: edges[name]
  };
  var options = {};
  network[name]= new vis.Network(container, data, options);
}

InitMap("cjdns");
InitMap("yggdrasil");

function UpdateNode(nodeID,name,edgeID,edgeLabel,map,NodeExist) {
  NodeExist[nodeID]=1;
  if (!nodeIDs[map][nodeID]) {
    name=name.substr(name.length-4,4);
    nodeIDs[map][nodeID]=nodes[map].add({id:nodeID, label:name});
  }
  if (!edgeIDs[map][edgeID]) {
    edgeIDs[map][edgeID] = edges[map].add({id: edgeID, from: nodeID, to: 0});
    console.debug(edgeID + "-" + nodeID);
  }
  edges[map].update({id: edgeID, label:edgeLabel });
}
function DeleteNodes(map,NodeExist) {
  for (var key in nodeIDs[map]) {
	if (NodeExist[key]!=1) {
		nodes[map].remove(key);
		nodeIDs[map][key]=undefined;
		console.log("gatta delete " + key);
	}
  }
}
