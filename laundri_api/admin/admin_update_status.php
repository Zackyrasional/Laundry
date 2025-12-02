<?php
require '../config.php';

$input = json_decode(file_get_contents("php://input"), true);

$id = $input["id"];
$status = $input["status"];
$weight = isset($input["weight_kg"]) ? $input["weight_kg"] : null;
$total  = isset($input["total_price"]) ? $input["total_price"] : null;

if ($weight === null || $total === null) {
    $query = "UPDATE reservations SET status='$status' WHERE id=$id";
} else {
    $query = "UPDATE reservations 
              SET status='$status', weight_kg=$weight, total_price=$total 
              WHERE id=$id";
}

if (mysqli_query($conn, $query)) {
    echo json_encode([
        "status" => "success",
        "message" => "Data reservasi berhasil diperbarui"
    ]);
} else {
    echo json_encode([
        "status" => "error",
        "message" => mysqli_error($conn)
    ]);
}
?>
