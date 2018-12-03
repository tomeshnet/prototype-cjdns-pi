// BASE32 code form CJDNS library
var numForAscii = [
  99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,
  99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,
  99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,
   0, 1, 2, 3, 4, 5, 6, 7, 8, 9,99,99,99,99,99,99,
  99,99,10,11,12,99,13,14,15,99,16,17,18,19,20,99,
  21,22,23,24,25,26,27,28,29,30,31,99,99,99,99,99,
  99,99,10,11,12,99,13,14,15,99,16,17,18,19,20,99,
  21,22,23,24,25,26,27,28,29,30,31,99,99,99,99,99,
];

// see util/Base32.h
var Base32_decode = function (input) {
  var output = [];

  var outputIndex = 0;
  var inputIndex = 0;
  var nextByte = 0;
  var bits = 0;

  while (inputIndex < input.length) {
      var o = input.charCodeAt(inputIndex);
      if (o & 0x80) { throw new Error(); }
      var b = numForAscii[o];
      inputIndex++;
      if (b > 31) { throw new Error("bad character " + input[inputIndex] + " in " + input); }

      nextByte |= (b << bits);
      bits += 5;

      if (bits >= 8) {
          output[outputIndex] = nextByte & 0xff;
          outputIndex++;
          bits -= 8;
          nextByte >>= 8;
      }
  }

  if (bits >= 5 || nextByte) {
      throw new Error("bits is " + bits + " and nextByte is " + nextByte);
  }
  return output;
};

// Convert Public Key to IPv6
// TODO add :
var publicKeyCache = [];
function public2IPv6(PubKey) {
if (!publicKeyCache[PubKey]) { 
  var IPv6=Base32_decode(PubKey);
  IPv6=sha512(sha512.array(IPv6));
  IPv6=IPv6.substr(0,32);
  publicKeyCache[PubKey]=IPv6;
}
return publicKeyCache[PubKey];
}




function loadXMLDoc() {
var xmlhttp = new XMLHttpRequest();
xmlhttp.onreadystatechange = function() {
  if (this.readyState == 4 && this.status == 200) {
    CJDNSMap(this);
  }
};
xmlhttp.open("GET", "/cgi-bin/peers", true);
xmlhttp.send();
}

function loadXMLDoc_y() {
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
  jsonDisplay=ajax.response.replace(new RegExp("'", "g"),"\"");
  Nodes=ToJson(jsonDisplay);
  for (var a=0; a< Nodes.peers.length; a++) {
      var parts=Nodes.peers[a].addr.split(".");
        UpdateNode(parts[5],public2IPv6(parts[5]),parts[4], Nodes.peers[a].recvKbps + "kpbs / " + Nodes.peers[a].sendKbps + " kbps","cjdns");
  }
  setTimeout("loadXMLDoc()",1000);
}

lastrx=[];
lasttx=[];
function YggdrasilMap(ajax) {
  var Nodes; 
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
          UpdateNode(addr,addr,node.port,rx + " bps /" + tx + " bps", "yggdrasil");
    }  
  }
  setTimeout("loadXMLDoc_y()",1000);
}

// Update Map
// vis.js Initalization

var nodeIDs=[];
var edgeIDs=[];
var nodesArray=[];
var edgesArray=[];
var nodes=[];
var edges=[];
var network=[];
//var nodeIds,edgesIDs,  nodesArray, nodes, edgesArray, edges, network;

function initMap(name) {
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
initMap("cjdns");
initMap("yggdrasil");

function UpdateNode(nodeID,name,edgeID,edgeLabel,map) {
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