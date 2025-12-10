<?php
require 'config.php';

$input = json_decode(file_get_contents("php://input"), true);

$name = $input["customer_name"];
$phone = $input["phone"];
$address = $input["address"];
$pickup_date = $input["pickup_date"];
$note = $input["note"];
$package_id = $input["package_id"];
$user_id = isset($input["user_id"]) ? intval($input["user_id"]) : "NULL";

$q = "INSERT INTO reservations 
        (customer_name, phone, address, pickup_date, note, package_id, user_id)
      VALUES 
        ('$name', '$phone', '$address', '$pickup_date', '$note', $package_id, $user_id)";

if (mysqli_query($conn, $q)) {
    echo json_encode(["status" => "success", "message" => "Reservasi berhasil disimpan"]);
} else {
    echo json_encode(["status" => "error", "message" => mysqli_error($conn)]);
}
?>
