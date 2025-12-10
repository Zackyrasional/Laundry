<?php
require 'config.php';

$user_id = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

$q = "SELECT r.*, 
             p.name AS package_name, 
             p.price_per_kg, 
             p.duration_hours,
             p.image_url
      FROM reservations r
      JOIN packages p ON r.package_id = p.id";

if ($user_id > 0) {
    $q .= " WHERE r.user_id = $user_id";
}

$q .= " ORDER BY r.id DESC";

$res = mysqli_query($conn, $q);

$data = [];
while ($row = mysqli_fetch_assoc($res)) {
    $data[] = $row;
}

echo json_encode($data);
?>
