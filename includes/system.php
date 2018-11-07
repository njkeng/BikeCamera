<?php
/**
*
* Find the version of the Raspberry Pi
* Currently only used for the system information page but may useful elsewhere
*
*/

function RPiVersion() {
  // Lookup table from http://www.raspberrypi-spy.co.uk/2012/09/checking-your-raspberry-pi-board-version/
  $revisions = array(
    '0002' => 'Model B Revision 1.0',
    '0003' => 'Model B Revision 1.0 + ECN0001',
    '0004' => 'Model B Revision 2.0 (256 MB)',
    '0005' => 'Model B Revision 2.0 (256 MB)',
    '0006' => 'Model B Revision 2.0 (256 MB)',
    '0007' => 'Model A',
    '0008' => 'Model A',
    '0009' => 'Model A',
    '000d' => 'Model B Revision 2.0 (512 MB)',
    '000e' => 'Model B Revision 2.0 (512 MB)',
    '000f' => 'Model B Revision 2.0 (512 MB)',
    '0010' => 'Model B+',
    '0013' => 'Model B+',
    '0011' => 'Compute Module',
    '0012' => 'Model A+',
    'a01041' => 'a01041',
    'a21041' => 'a21041',
    '900092' => 'PiZero 1.2',
    '900093' => 'PiZero 1.3',
    '9000c1' => 'PiZero W',
    'a02082' => 'Pi 3 Model B',
    'a22082' => 'Pi 3 Model B'
  );
  exec('cat /proc/cpuinfo', $cpuinfo_array);
  $rev = trim(array_pop(explode(':',array_pop(preg_grep("/^Revision/", $cpuinfo_array)))));
  if (array_key_exists($rev, $revisions)) {
    return $revisions[$rev];
  } else {
    return 'Unknown Pi';
  }
}

/**
*
*
*/
function DisplaySystem(){
  $status = new StatusMessages();

  // mem used
  $memused_status = "primary";
  exec("free -m | awk '/Mem:/ { total=$2 ; used=$3 } END { print used/total*100}'", $memarray);
  $memused = floor($memarray[0]);
  if     ($memused > 90) { $memused_status = "danger";  }
  elseif ($memused > 75) { $memused_status = "warning"; }
  elseif ($memused >  0) { $memused_status = "success"; }

  // cpu load
  $cores   = exec("grep -c ^processor /proc/cpuinfo");
  $loadavg = exec("awk '{print $1}' /proc/loadavg");
  $cpuload = floor(($loadavg * 100) / $cores);
  if     ($cpuload > 90) { $cpuload_status = "danger";  }
  elseif ($cpuload > 75) { $cpuload_status = "warning"; }
  elseif ($cpuload >  0) { $cpuload_status = "success"; }

  // SD card space
  $sparebytes   = (disk_total_space("/") - disk_free_space("/")) / disk_total_space("/");
  $sparespace = floor($sparebytes * 100);
  if     ($sparespace > 95) { $space_status = "danger";  }
  elseif ($sparespace > 90) { $space_status = "warning"; }
  elseif ($sparespace >  0) { $space_status = "success"; }

  // Get WiFi information
  exec("hostname -f", $hostarray);
  $hostname = $hostarray[0];
  exec( 'ip a s ' . RASPI_WIFI_CLIENT_INTERFACE , $return );
  exec( 'iwconfig ' . RASPI_WIFI_CLIENT_INTERFACE, $return );

  $strWlan0 = implode( " ", $return );
  $strWlan0 = preg_replace( '/\s\s+/', ' ', $strWlan0 );

  // Parse results from ifconfig/iwconfig
  preg_match_all( '/inet ([0-9.]+)/i',$strWlan0,$result ) || $result[1] = 'No IP Address Found';
  $strIPAddress = '';
  foreach($result[1] as $ip) {
      $strIPAddress .= $ip." ";
  }
  preg_match( '/ESSID:\"([a-zA-Z0-9\s].+)\"/i',$strWlan0,$result ) || $result[1] = 'Not connected';
  $strSSID = str_replace( '"','',$result[1] );

?>
  <div class="row">
    <div class="col-lg-12">
      <div class="panel panel-primary"> 
		<div class="panel-heading"><i class="fa fa-cube fa-fw"></i> System</div>
		<div class="panel-body">
		    <?php
		    if (isset($_POST['system_reboot'])) {
		      echo '<div class="alert alert-warning">System Rebooting Now!</div>';
		      $result = shell_exec("sudo /sbin/reboot");
		    }
		    if (isset($_POST['system_shutdown'])) {
		      echo '<div class="alert alert-warning">System Shutting Down Now!</div>';
		      $result = shell_exec("sudo /sbin/shutdown -h now");
		    }
		    ?>
		    <p><?php $status->showMessages(); ?></p>
            <div class="row">
              <div class="col-md-6">
              	<div class="panel panel-default">
                  <div class="panel-body">
		            <h4>WiFi Information</h4>
		            <div class="info-item">Hostname</div> <?php echo $hostname ?></br>
          			<div class="info-item">Connected To</div>   <?php echo $strSSID ?></br>
		      		<div class="info-item">IP address</div> <?php echo $strIPAddress ?></br>
                  </div><!-- /.panel-body -->
	            </div><!-- /.panel-default -->
              </div><!-- /.col-md-6 -->
            </div><!-- /.row -->

            <div class="row">
              <div class="col-md-6">
              	<div class="panel panel-default">
                  <div class="panel-body">
		            <h4>System Information</h4>
		            <div class="info-item">Pi Revision</div> <?php echo RPiVersion() ?></br></br>
		            <div class="info-item">SD Card Capacity</div>
		            <div class="progress">
		                <div class="progress-bar progress-bar-<?php echo $space_status ?> progress-bar-striped active"
		                role="progressbar"
		                aria-valuenow="<?php echo $sparespace ?>" aria-valuemin="0" aria-valuemax="100"
		                style="width: <?php echo $sparespace ?>%;"><?php echo $sparespace ?>%
		                </div>
		            </div>
		            <div class="info-item">Memory Used</div>
		            <div class="progress">
		                <div class="progress-bar progress-bar-<?php echo $memused_status ?> progress-bar-striped active"
		                role="progressbar"
		                aria-valuenow="<?php echo $memused ?>" aria-valuemin="0" aria-valuemax="100"
		                style="width: <?php echo $memused ?>%;"><?php echo $memused ?>%
		                </div>
		            </div>
		            <div class="info-item">CPU Load</div>
		            <div class="progress">
		                <div class="progress-bar progress-bar-<?php echo $cpuload_status ?> progress-bar-striped active"
		                role="progressbar"
		                aria-valuenow="<?php echo $cpuload ?>" aria-valuemin="0" aria-valuemax="100"
		                style="width: <?php echo $cpuload ?>%;"><?php echo $cpuload ?>%
		                </div>
		            </div>

		            <form action="?page=system_info" method="POST">
		                <input type="submit" class="btn btn-warning" name="system_reboot"   value="Reboot" />
		                <input type="submit" class="btn btn-warning" name="system_shutdown" value="Shutdown" />
		                <input type="button" class="btn btn-outline btn-primary" value="Refresh" onclick="document.location.reload(true)" />
		            </form>
                  </div><!-- /.panel-body -->
	            </div><!-- /.panel-default -->
              </div><!-- /.col-md-6 -->
            </div><!-- /.row -->
        </div><!-- /.panel-body -->
      </div><!-- /.panel-default -->
    </div><!-- /.col-lg-12 -->
  </div><!-- /.row -->

<?php 

}

?>
