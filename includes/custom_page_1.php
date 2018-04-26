<?php

include_once( 'includes/status_messages.php' );

/*
* UI for setting video parameters
*
*/
function DisplayCustomPage1(){

  $status = new StatusMessages();

  # Options for video clip length
  $vid_length = array(2, 5, 10, 15);
  $cull_free_space = array(100, 200, 500, 1000);
  $vid_datetime_size = array(12, 15, 20, 25, 32, 45);
  $ffmpeg_output_format = array('mp4', 'mkv');

  # Video resolutions for raspberry pi camera
  # 1080p widescreen 1920x1080 30fps
  # 1080p SD 1440x1080 30fps
  # 720p widescreen 1280x720 40fps
  # 720p SD 960x720 40fps
  # VGA 640x480 60fps
  $picamera_resolution = array('1080p_HD','1080p_SD','720p_HD','720p_SD','VGA');

  # Read existing configuration data, else use default data
  if ( ! $video_ini = parse_ini_file('/etc/pihelmetcam/video/video.ini')) {
    $status->addMessage('Could not find an existing configuration file', 'warning');
  }

  if( isset($_POST['saveCP1settings']) ) {
    if (CSRFValidate()) {
      SaveCustomPage1($status, $video_ini);
    } else {
      error_log('CSRF violation');
    }
  }

  ?>

  <div class="row">
    <div class="col-lg-12">
      <div class="panel panel-primary">           
        <div class="panel-heading"><i class="fa <?php echo RASPI_CUSTOMPAGE1_ICON; ?> fa-fw"></i> Video settings</div>
        <!-- /.panel-heading -->
        <div class="panel-body">
          <p><?php $status->showMessages(); ?></p>

          <form method="POST" action="?page=custompage1_conf" name="video_conf_form" class="form-horizontal">
            <?php CSRFToken() ?>
            <input type="hidden" name="video_settings" ?>
   
          <div class="col-md-6">  <!-- for CAPTURE SETTINGS -->
            <div class="panel panel-default">
              <div class="panel-body">
                  <h4>Capture settings</h4>
                  <br>

                  <div class="form-group">
                    <label for="picamera_resolution" class="col-sm-4 control-label">Quality</label>
                    <div class="col-sm-5">
                      <?php SelectorOptions('picamera_resolution', $picamera_resolution, $video_ini['picamera_resolution']); ?>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="ffmpeg_output_format" class="col-sm-4 control-label">Output format</label>
                    <div class="col-sm-5">
                      <?php SelectorOptions('ffmpeg_output_format', $ffmpeg_output_format, $video_ini['ffmpeg_output_format']); ?>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="picamera_hflip" class="col-sm-4 control-label">Flip horizontally</label>
                    <div class="radio" id="picamera_hflip">
                      <div class="col-sm-2">
                        <input type="radio" name="picamera_hflip" value="0" <?php if($video_ini['picamera_hflip']==0) { echo "checked"; } ?>>
                    Normal
                      </div>
                      <div class="col-sm-2">
                        <input type="radio" name="picamera_hflip" id="picamera_hflip" value="1" <?php if($video_ini['picamera_hflip']==1) { echo "checked"; } ?>>
                    Flip
                      </div>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="picamera_vflip" class="col-sm-4 control-label">Flip vertically</label>
                    <div class="radio" id="picamera_vflip">
                      <div class="col-sm-2">
                        <input type="radio" name="picamera_vflip" value="0" <?php if($video_ini['picamera_vflip']==0) { echo "checked"; } ?>>
                    Normal
                      </div>
                      <div class="col-sm-2">
                        <input type="radio" name="picamera_vflip" id="picamera_vflip" value="1" <?php if($video_ini['picamera_vflip']==1) { echo "checked"; } ?>>
                    Flip
                      </div>
                    </div>
                  </div>

              </div><!-- /.panel-body -->
            </div><!-- /.panel-default -->
          </div><!-- /.col-md-6 for CAPTURE SETTINGS -->

          <div class="col-md-6"> <!-- for STORAGE SETTINGS -->
            <div class="panel panel-default">
              <div class="panel-body">
                  <h4>Storage settings</h4>
                  <br>

                  <div class="form-group">
                    <label for="vid_length" class="col-sm-4 control-label">Video clip length </label>
                    <div class="input-group">
                      <?php SelectorOptions('vid_length', $vid_length, $video_ini['vid_length']); ?>
                      <div class="input-group-addon">minutes</div>
                    </div>
                  </div>

                  <div class="form-group">
                    <label for="cull_free_space" class="col-sm-4 control-label">SD card keep free </label>
                    <div class="input-group">
                      <?php SelectorOptions('cull_free_space', $cull_free_space, $video_ini['cull_free_space']); ?>
                      <div class="input-group-addon">MB</div>
                    </div>
                  </div>

              </div><!-- /.panel-body -->
            </div><!-- /.panel-default -->
          </div><!-- /.col-md-6 for STORAGE SETTINGS -->

          <div class="col-md-6"> <!-- for OVERLAY SETTINGS -->
            <div class="panel panel-default">
              <div class="panel-body">
                  <h4>Overlay settings</h4>
                  <br>

                  <div class="form-group">
                    <label for="vid_datetime_enable" class="col-sm-4 control-label">Time and date</label>
                    <div class="radio" id="vid_datetime_enable">
                      <div class="col-sm-2">
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
                    <div class="input-group">
                      <?php SelectorOptions('vid_datetime_size', $vid_datetime_size, $video_ini['vid_datetime_size']); ?>
                      <div class="input-group-addon">Pixels</div>
                    </div>
                  </div>

              </div><!-- /.panel-body -->
            </div><!-- /.panel-default -->
          </div><!-- /.col-md-6 for OVERLAY SETTINGS -->


          <input type="submit" class="btn btn-outline btn-primary" name="saveCP1settings" value="Save settings" />
          </form>
        </div><!-- ./ Panel body -->
        <div class="panel-footer"></div>
      </div><!-- /.panel-primary -->
    </div><!-- /.col-lg-12 -->
  </div><!-- /.row -->

<?php 
}

function SaveCustomPage1($status, $video_ini) {

    # Copy original video.ini data
    $ini_data = $video_ini;

    # Save new data to video.ini
    $ini_data ['picamera_resolution']   = $_POST['picamera_resolution'];
    $ini_data ['vid_length']            = $_POST['vid_length'];
    $ini_data ['cull_free_space']       = $_POST['cull_free_space'];
    $ini_data ['vid_datetime_size']     = $_POST['vid_datetime_size'];
    $ini_data ['vid_datetime_enable']   = $_POST['vid_datetime_enable'];
    $ini_data ['picamera_hflip']        = $_POST['picamera_hflip'];
    $ini_data ['picamera_vflip']        = $_POST['picamera_vflip'];
    $ini_data ['ffmpeg_output_format']  = $_POST['ffmpeg_output_format'];

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
        $ini_data ['picamera_framerate']  = 60;
        break;

    }

    if ( write_php_ini($ini_data,'/etc/pihelmetcam/video/video.ini')) {
      $status->addMessage('Successfully saved configuration data', 'success');
    } else {
      $status->addMessage('Unable to save configuration data', 'danger');
      return false;
    }

  return true;
}
?>


    