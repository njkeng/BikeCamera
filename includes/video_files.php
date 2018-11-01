<?php

include_once( 'includes/status_messages.php' );

/**
*
* Display and manage recorded video files
*
*/

function DisplayVideoFiles(){
  $status = new StatusMessages();  

  # Read video files
  $base_dir = "/var/www/html/";
  $completed_path = "video/completed/";
  if ( ! $completed_files = scandir($base_dir.$completed_path)) {
    $status->addMessage('Could not read video files from "Completed" directory', 'warning');
  }
  # Remove unwanted . and .. files from the array
  unset($completed_files[0]);
  unset($completed_files[1]);

?>
  <div class="row">
    <div class="col-lg-12">
      <div class="panel panel-primary">
        <div class="panel-heading"><i class="fa fa-file-movie-o fa-fw"></i>Video files</div>
          <div class="panel-body">
            <form role="form" action="?page=video_files_conf" method="POST">
              <input type="submit" class="btn btn-outline btn-primary" name="download_zip" value="Download zip of selected video files" />
              <h4>Processed video files</h4>
              <?php CSRFToken() ?>
              <div class="row">
                <div class="form-group col-md-4">
                  <label for="checkbox">Files</label>
                  <div class="checkbox">
                    <label>
                      <?php foreach ($completed_files as &$value) {
                        echo "<input type='checkbox' name='completed_file[]' value='".$completed_path.$value."'> <a href='".$completed_path.$value."' target='_black' >".$value."</a>   ".formatSizeUnits(filesize($completed_path.$value))."<br/>";
                        } 
                      ?>
                    </label>
                  </div>
                </div>
              </div>
            </form>
        </div><!-- /.panel-body -->
      </div><!-- /.panel-default -->
    </div><!-- /.col-lg-12 -->
  </div><!-- /.row -->
<?php 
}

?>
