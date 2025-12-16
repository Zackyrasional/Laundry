<?php
require '../config.php';
header('Content-Type: application/json');

$raw = file_get_contents("php://input");
$input = json_decode($raw, true);

$name = $input["name"] ?? null;
$price = $input["price_per_kg"] ?? null;
$duration = $input["duration_hours"] ?? null;
$image = $input["image_url"] ?? null;

if (!$name || $price === null || $duration === null || !$image) {
  echo json_encode(["status"=>"error","message"=>"Field wajib: name, price_per_kg, duration_hours, image_url"]);
  exit;
}

$name = mysqli_real_escape_string($conn, $name);
$price = (int)$price;
$duration = (int)$duration;
$image = mysqli_real_escape_string($conn, $image);

$sql = "INSERT INTO packages (name, price_per_kg, duration_hours, image_url)
        VALUES ('$name', $price, $duration, '$image')";

if (mysqli_query($conn, $sql)) {
  echo json_encode(["status"=>"success","message"=>"Paket berhasil ditambahkan"]);
} else {
  echo json_encode(["status"=>"error","message"=>mysqli_error($conn)]);
}
