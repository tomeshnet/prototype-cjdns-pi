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
      UpdateMap(this);
    }
  };
  xmlhttp.open("GET", "/cgi-bin/peers", true);
  xmlhttp.send();
}

function ToJson(json) {
  // Cleanup the json provided by the libraries
  // Otherwise it will not parse properly
  // ToDo - this is really hacking, there should be a better way of doing this
  json=json.replace(new RegExp("}", "g"),"\"null\": \"\"}");
  json=json.replace(new RegExp("  ","g")," ");
  json=json.replace(new RegExp("  ","g")," ");
  json=json.replace(new RegExp("\n","g")," ");
  json=json.replace("},  ]","}]");

  // Parse it
  return JSON.parse(json);  
}
var mtnodes;
function UpdateMap(xml) {
  jsonDisplay=xml.response.replace(new RegExp("'", "g"),"\"");
  mtnodes=ToJson(jsonDisplay);
  for (var a=0; a< mtnodes.peers.length; a++) {
  	var parts=mtnodes.peers[a].addr.split(".");
  	UpdateNode(parts[5],parts[4], mtnodes.peers[a].recvKbps + "kpbs / " + mtnodes.peers[a].sendKbps + " kbps");
  }
  setTimeout("loadXMLDoc()",1000);
}


// Update Map

// vis.js Initalization

var nodeIds,edgesIDs, shadowState, nodesArray, nodes, edgesArray, edges, network;

nodeIds = [];
edgesIDs = [];
linkIds = [];
nodesArray = [
  {id: 0, label: 'Me'}
];
nodes = new vis.DataSet(nodesArray);

edgesArray = [
];
edges = new vis.DataSet(edgesArray);

 // create a network
        var container = document.getElementById('mynetwork');
        var data = {
            nodes: nodes,
            edges: edges
        };
        var options = {};
        network = new vis.Network(container, data, options);


function UpdateNode(newId,edgeID,edgeLabel) {

	if (!nodeIds[newId]) {
    name=public2IPv6(newId);
    name=name.substr(name.length-4,4);
    nodeIds[newId]=nodes.add({id:newId, label:name});
	}
  if (!edgesIDs[edgeID]) {
    edgesIDs[edgeID] = edges.add({from: newId, to: 0});
  }

  edges.update({id: edgesIDs[edgeID][0], label:edgeLabel });

}    



