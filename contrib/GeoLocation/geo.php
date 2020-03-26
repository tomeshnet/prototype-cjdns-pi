<?php
// Place on a server as proxy for hideing the google API key
$apiKey="<YOUR GOOGLE API KEY FOR GEO LOCATION";

$json= file_get_contents('php://input');
$json = str_replace(",}}","}}",$json);

$url='https://www.googleapis.com/geolocation/v1/geolocate?key=' . $apiKey;

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, $json);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
$result = curl_exec($ch);
echo $result;
?>
