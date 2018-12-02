<?php

include_once( 'includes/status_messages.php' );

/*
*
* Display and manage recorded video files
*
*/

function DisplayVideoFiles(){
  $status = new StatusMessages();  

  # Read video files
  $base_dir = "/var/www/html/";
  $completed_path = "video/completed/";
  if ( ! $completed_files = scandir($base_dir.$completed_path, SCANDIR_SORT_DESCENDING)) {
    $status->addMessage('Could not read video files from "Completed" directory', 'warning');
  }
  # Remove unwanted . and .. files from the array
  unset($completed_files[count($completed_files)-1]);
  unset($completed_files[count($completed_files)-1]);

  $mp4_path = "video/mp4/";
  if ( ! $mp4_files = scandir($base_dir.$mp4_path)) {
    $status->addMessage('Could not read video files from "mp4" directory', 'warning');
  }
  # Remove unwanted . and .. files from the array
  unset($mp4_files[0]);
  unset($mp4_files[1]);

?>
  <div class="row">
    <div class="col-lg-12">
      <div class="panel panel-primary">
        <div class="panel-heading"><i class="fa fa-file-movie-o fa-fw"></i>Video files</div>
        <div class="panel-body">
          <div class="row">
          <label for="notes">  Notes:</label>
            <ul id="notes">
              <li>Processing converts raw video files into standard .mp4</li>
              <li>Processing only occurs when recording is Stopped</li>
              <li>Processing is slow.  It takes about the same time as it took to record.</li>
            </ul>
          </div>
          <!-- Nav tabs -->
          <ul class="nav nav-tabs">
            <li class="active">
                <a href="#processed" data-toggle="tab">mp4 files</a>
            </li>
            <li>
              <a href="#unprocessed" data-toggle="tab">Raw files</a>
            </li>
          </ul>

          <!-- Tab panes -->
          <div class="tab-content">

            <div class="tab-pane fade in active" id="processed">

              <?php CSRFToken() ?>
              <div class="row">
                <div class="form-group col-md-4">
                  <?php if (count($mp4_files) < 1) {
                    echo "<h4>There are no video files</h4>";
                  } else {
                    echo "<h4></h4>";
                    echo "<label for='processed_list'>Right click to download / save</label>";
                    echo "<ul class='list-unstyled' id='processed_list'>";
                    foreach ($mp4_files as &$value) {
                      echo "<li><a href='".$mp4_path.$value."' target='_black' >".$value."</a>   ".formatSizeUnits(filesize($mp4_path.$value))."</li>";
                      }
                    echo "</ul>";
                  } ?>
                </div>
              </div>
            </div>

            <div class="tab-pane fade" id="unprocessed">

              <div class="row">
                <div class="form-group col-md-4">

                  <?php if (count($completed_files) < 1) {
                    echo "<h4>All files have been processed</h4>";
                  } else {
                    echo "<h4></h4>";
                    echo "<label for='processed_list'>Right click to download / save</label>";
                    echo "<ul class='list-unstyled' id='processed_list'>";
                    foreach ($completed_files as &$value) {
                      echo "<li><a href='".$completed_path.$value."' target='_black' >".$value."</a>   ".formatSizeUnits(filesize($completed_path.$value))."</li>";
                      }
                    echo "</ul>";
                  } ?>

                </div>
              </div>
            </div>

          </div>
        </div><!-- /.panel-body -->
      </div><!-- /.panel-default -->
    </div><!-- /.col-lg-12 -->
  </div><!-- /.row -->
<?php 
}

?>
