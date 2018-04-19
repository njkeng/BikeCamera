<?php

$config = array(
  'admin_user' => 'admin',
  'admin_pass' => '$2y$10$YKIyWAmnQLtiJAy6QgHQ.eCpY4m.HCEbiHaTgN6.acNC6bDElzt.i'
);

if(file_exists(RASPI_CONFIG.'/pihelmetcam.auth')) {
    if ( $auth_details = fopen(RASPI_CONFIG.'/pihelmetcam.auth', 'r') ) {
      $config['admin_user'] = trim(fgets($auth_details));
      $config['admin_pass'] = trim(fgets($auth_details));
      fclose($auth_details);
    }
}
?>
