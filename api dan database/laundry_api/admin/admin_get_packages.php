<?php
require '../config.php';
header('Content-Type: application/json');

$q = mysqli_query($conn, "SELECT id, name, price_per_kg, duration_hours, image_url FROM packages ORDER BY id DESC");
$data = [];
while ($row = mysqli_fetch_assoc($q)) $data[] = $row;

echo json_encode([
  "status" => "success",
  "data" => $data
]);
