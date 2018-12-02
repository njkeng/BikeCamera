<?php

include_once( 'includes/status_messages.php' );

/*
* UI for setting video parameters
*
*/
function DisplayVideoSettings(){

  $status = new StatusMessages();

  # Options for video clip length
  $vid_length = array(2, 5, 10, 15);
  $cull_free_space = array(500, 1000, 2000, 3000, 4000);
  $vid_datetime_size = array(12, 15, 20, 25, 32, 45);
  $picamera_quality = array(20, 22, 24, 26);
  $picamera_rotation = array(0, 90, 180, 270);
  $picamera_bitrate = array(1, 3, 5, 7, 9, 11, 13, 15, 17);
  $picamera_awb_modes = array('auto','sunlight','cloudy','shade','tungsten','fluorescent','incandescent','flash','horizon');
  $picamera_exp_modes = array('auto','night','nightpreview','backlight','spotlight','sports','snow','beach','verylong','fixedfps','antishake','fireworks');

  # Video resolutions for raspberry pi camera
  # 1080p widescreen 1920x1080 30fps
  # 1080p SD 1440x1080 30fps
  # 720p widescreen 1280x720 40fps
  # 720p SD 960x720 40fps
  # VGA 640x480 60fps
  $picamera_resolution = array('1080p_HD','1080p_SD','720p_HD','720p_SD','VGA');


  # Check for command to save settings
  #
  if( isset($_POST['save_settings']) ) {
    if (CSRFValidate()) {
      # Read existing configuration data, else use default data
      if ( ! $video_ini = parse_ini_file('/etc/bikecamera/video/video.ini')) {
        $status->addMessage('Could not find an existing configuration file', 'warning');
      }
      SaveVideoSettings($status, $video_ini);
    } else {
      error_log('CSRF violation');
    }
  }

  # Check for command to start recording
  #
  if( isset($_POST['start_recording']) ) {
    if (CSRFValidate()) {
      # Read existing status data, else use default data
      if ( ! $status_ini = parse_ini_file('/etc/bikecamera/video/status.ini')) {
        $status->addMessage('Could not find an existing status file', 'warning');
      }
      # Write start command to status.ini
      $status_ini ['status_start']  = "1";
      if ( write_php_ini($status_ini,'/etc/bikecamera/video/status.ini')) {
        $status->addMessage('Start command sent', 'success');
        sleep(2);
      } else {
        $status->addMessage('Unable to send the start command', 'danger');
        return false;
      }
    } else {
      error_log('CSRF violation');
    }
  }

  # Check for command to stop recording
  #
  if( isset($_POST['stop_recording']) ) {
    if (CSRFValidate()) {
      # Read existing status data, else use default data
      if ( ! $status_ini = parse_ini_file('/etc/bikecamera/video/status.ini')) {
        $status->addMessage('Could not find an existing status file', 'warning');
      }
      # Write stop command to status.ini
      $status_ini ['status_stop']  = "1";
      if ( write_php_ini($status_ini,'/etc/bikecamera/video/status.ini')) {
        $status->addMessage('Stop command sent', 'success');
        sleep(2);
      } else {
        $status->addMessage('Unable to send the stop command', 'danger');
        return false;
      }
    } else {
      error_log('CSRF violation');
    }
  }

  # Check camera status
  #
  # Read existing status data, else use default data
  if ( ! $status_ini = parse_ini_file('/etc/bikecamera/video/status.ini')) {
    $status->addMessage('Could not find an existing status file', 'warning');
  }
  # Output status of the camera
  if ( $status_ini ['status_current'] == "1" ) {
    $status->addMessage('Camera is recording', 'success');
  } else {
    $status->addMessage('Camera is not recording', 'danger');
  }

  # Read existing configuration data
  if ( ! $video_ini = parse_ini_file('/etc/bikecamera/video/video.ini')) {
    $status->addMessage('Could not find an existing configuration file', 'warning');
  }

  ?>

  <div class="row">
    <div class="col-lg-12">
      <div class="panel panel-primary">           
        <div class="panel-heading"><i class="fa fa-video-camera fa-fw"></i> Video settings</div>
        <!-- /.panel-heading -->
        <div class="panel-body">

        <?php
        if (isset($_POST['system_reboot'])) {
          echo '<div class="alert alert-warning">System Rebooting Now!   ';
          echo '<input type="button" class="btn btn-outline btn-primary" value="Reload page" onclick="document.location.reload(true)" />';
          echo '</div>';
          $result = shell_exec("sleep 5s; sudo /sbin/reboot > /dev/null 2>/dev/null &");
        }
        ?>

          <p><?php $status->showMessages(); ?></p>

          <form method="POST" action="?page=videosettings_conf" name="video_conf_form" class="form-horizontal">
            <?php CSRFToken() ?>
            <input type="hidden" name="video_settings" ?>

            <h4>
              <div class="btn-group btn-block">
                <input type="submit" class="col-md-2 btn btn-success" name="start_recording" value="Start recording" />
                <input type="submit" class="col-md-2 btn btn-danger" name="stop_recording" value="Stop recording" />
              </div><!-- /.btn-group -->
            </h4>

              <!-- Nav tabs -->
              <ul class="nav nav-tabs">
                <li class="active">
                    <a href="#capture" data-toggle="tab">Capture</a>
                </li>
                <li>
                  <a href="#storage" data-toggle="tab">Storage</a>
                </li>
                <li>
                  <a href="#overlay" data-toggle="tab">Overlay</a>
                </li>
                <li>
                  <a href="#advanced" data-toggle="tab">Advanced</a>
                </li>
              </ul>

              <!-- Tab panes -->
              <div class="tab-content">

                <div class="tab-pane fade in active" id="capture">
                  <h4>Capture settings</h4>
                  <br>

                  <div class="form-group">
                    <label for="picamera_resolution" class="col-sm-4 control-label">Quality</label>
                    <div class="col-sm-3">
                      <?php SelectorOptions('picamera_resolution', $picamera_resolution, $video_ini['picamera_resolution']); ?>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="picamera_rotation" class="col-sm-4 control-label">Video rotation</label>
                    <div class="col-sm-3">
                      <?php SelectorOptions('picamera_rotation', $picamera_rotation, $video_ini['picamera_rotation']); ?>
                    </div>
                  </div>

                </div><!-- /.tab-pane  -->

                <div class="tab-pane fade" id="storage">
                  <h4>Storage settings</h4>
                  <br>

                  <div class="form-group">
                    <label for="vid_length" class="col-sm-4 control-label">Video clip length </label>
                    <div class="input-group col-sm-3">
                      <?php SelectorOptions('vid_length', $vid_length, $video_ini['vid_length']); ?>
                      <div class="input-group-addon">minutes</div>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="cull_free_space" class="col-sm-4 control-label">SD card keep free </label>
                    <div class="input-group col-sm-3">
                      <?php SelectorOptions('cull_free_space', $cull_free_space, $video_ini['cull_free_space']); ?>
                      <div class="input-group-addon">MB</div>
                    </div>
                  </div>
                </div><!-- /.tab-pane  -->

                <div class="tab-pane fade" id="overlay">
                  <h4>Overlay settings</h4>
                  <br>

                  <div class="form-group">
                    <label for="vid_datetime_enable" class="col-sm-4 control-label">Time and date</label>
                    <div class="radio col-sm-5" id="vid_datetime_enable">
                      <div class="col-sm-3">
                        <input type="radio" name="vid_datetime_enable" value="1" <?php if($video_ini['vid_datetime_enable']==1) { echo "checked"; } ?>>
                    Enable
                      </div>
                      <div class="col-sm-2">
                        <input type="radio" name="vid_datetime_enable" id="vid_datetime_enable" value="0" <?php if($video_ini['vid_datetime_enable']==0) { echo "checked"; } ?>>
                    Disable
                      </div>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="vid_datetime_size" class="col-sm-4 control-label">Text height</label>
                    <div class="input-group col-sm-3">
                      <?php SelectorOptions('vid_datetime_size', $vid_datetime_size, $video_ini['vid_datetime_size']); ?>
                      <div class="input-group-addon">Pixels</div>
                    </div>
                  </div>
                </div><!-- /.tab-pane  -->

                <div class="tab-pane fade" id="advanced">
                  <h4>Advanced settings</h4>
                  <br>

                  <div class="form-group">
                    <label for="picamera_quality" class="col-sm-4 control-label">Video quality</label>
                    <div class="input-group col-sm-3">
                      <?php SelectorOptions('picamera_quality', $picamera_quality, $video_ini['picamera_quality']); ?>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="picamera_bitrate" class="col-sm-4 control-label">Video bitrate</label>
                    <div class="input-group col-sm-3">
                      <?php SelectorOptions('picamera_bitrate', $picamera_bitrate, $video_ini['picamera_bitrate']); ?>
                      <div class="input-group-addon">Mb/s</div>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="picamera_awb_mode" class="col-sm-4 control-label">Automatic white balance</label>
                    <div class="input-group col-sm-3">
                      <?php SelectorOptions('picamera_awb_mode', $picamera_awb_modes, $video_ini['picamera_awb_mode']); ?>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="picamera_exp_mode" class="col-sm-4 control-label">Exposure mode</label>
                    <div class="input-group col-sm-3">
                      <?php SelectorOptions('picamera_exp_mode', $picamera_exp_modes, $video_ini['picamera_exp_mode']); ?>
                    </div>
                  </div>

                </div><!-- /.tab-pane  -->

              </div><!-- /.tab-content  -->

            <input type="submit" class="btn btn-outline btn-primary" name="save_settings" value="Save settings" />
            <input type="submit" class="btn btn-warning" name="system_reboot"   value="Reboot" />

          </form>
        </div><!-- ./ Panel body -->
        <div class="panel-footer"></div>
      </div><!-- /.panel-primary -->
    </div><!-- /.col-lg-12 -->
  </div><!-- /.row -->

<?php 
}

function SaveVideoSettings($status, $video_ini) {

    # Copy original video.ini data
    $ini_data = $video_ini;

    # Save new data to video.ini
    $ini_data ['picamera_resolution']   = $_POST['picamera_resolution'];
    $ini_data ['vid_length']            = $_POST['vid_length'];
    $ini_data ['cull_free_space']       = $_POST['cull_free_space'];
    $ini_data ['vid_datetime_size']     = $_POST['vid_datetime_size'];
    $ini_data ['vid_datetime_enable']   = $_POST['vid_datetime_enable'];
    $ini_data ['picamera_rotation']     = $_POST['picamera_rotation'];
    $ini_data ['picamera_quality']      = $_POST['picamera_quality'];
    $ini_data ['picamera_bitrate']      = $_POST['picamera_bitrate'];
    $ini_data ['picamera_awb_mode']     = $_POST['picamera_awb_mode'];
    $ini_data ['picamera_exp_mode']     = $_POST['picamera_exp_mode'];

    switch($_POST['picamera_resolution']){

      case "1080p_HD":
        $ini_data ['picamera_hres']       = 1920;
        $ini_data ['picamera_vres']       = 1080; 
        $ini_data ['picamera_framerate']  = 30;
        break;

        
      case "1080p_SD":
        $ini_data ['picamera_hres']       = 1440;
        $ini_data ['picamera_vres']       = 1080; 
        $ini_data ['picamera_framerate']  = 30;
        break;

      case "720p_HD":
        $ini_data ['picamera_hres']       = 1280;
        $ini_data ['picamera_vres']       = 720;
        $ini_data ['picamera_framerate']  = 40;
        break;

      case "720p_SD":
        $ini_data ['picamera_hres']       = 960;
        $ini_data ['picamera_vres']       = 720; 
        $ini_data ['picamera_framerate']  = 40;
        break;

      case "VGA":
        $ini_data ['picamera_hres']       = 640;
        $ini_data ['picamera_vres']       = 480; 
        $ini_data ['picamera_framerate']  = 40;
        break;

    }

    if ( write_php_ini($ini_data,'/etc/bikecamera/video/video.ini')) {
      $status->addMessage('Successfully saved configuration. Reboot for settings to take effect', 'success');
    } else {
      $status->addMessage('Unable to save configuration data', 'danger');
      return false;
    }

  return true;
}

?>


    