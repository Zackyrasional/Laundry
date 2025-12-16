<?php
require '../config.php';
header('Content-Type: application/json');

$raw = file_get_contents("php://input");
$input = json_decode($raw, true);

$id = $input["id"] ?? null;
$name = $input["name"] ?? null;
$price = $input["price_per_kg"] ?? null;
$duration = $input["duration_hours"] ?? null;
$image = $input["image_url"] ?? null;

if (!$id || !$name || $price === null || $duration === null || !$image) {
  echo json_encode(["status"=>"error","message"=>"Field wajib: id, name, price_per_kg, duration_hours, image_url"]);
  exit;
}

$id = (int)$id;
$name = mysqli_real_escape_string($conn, $name);
$price = (int)$price;
$duration = (int)$duration;
$image = mysqli_real_escape_string($conn, $image);

$sql = "UPDATE packages
        SET name='$name', price_per_kg=$price, duration_hours=$duration, image_url='$image'
        WHERE id=$id";

if (mysqli_query($conn, $sql)) {
  echo json_encode(["status"=>"success","message"=>"Paket berhasil diupdate"]);
} else {
  echo json_encode(["status"=>"error","message"=>mysqli_error($conn)]);
}
