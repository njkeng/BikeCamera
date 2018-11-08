<?php

include_once( 'includes/status_messages.php' );

/*
* Example script for a custom settings page
* Based on includes/hostapd.php script
*
*/
function DisplayTime(){

  $status = new StatusMessages();

  exec("date '+%Y'", $curr_year);
  exec("date '+%b'", $curr_month);
  exec("date '+%d'", $curr_day);
  exec("date '+%H'", $curr_hour);
  exec("date '+%M'", $curr_minute);

  # Definition of dropdown list options
  $arrYear = array('2018','2019','2020','2021','2022','2023','2024','2025','2026','2027','2028','2029','2030','2031','2032','2033','2034','2035','2036','2037','2038','2039','2040');
  $arrMonth = array('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
  $arrDay = array('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31');
  $arrHour = array('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24');
  $arrMinute = array('00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45','46','47','48','49','50','51','52','53','54','55','56','57','58','59');


  if( isset($_POST['setdate']) ) {
    if (CSRFValidate()) {
      SetDate($status);
    } else {
      error_log('CSRF violation');
    }
  }

  if( isset($_POST['settime']) ) {
    if (CSRFValidate()) {
      SetTime($status);
    } else {
      error_log('CSRF violation');
    }
  }

  ?>

  <div class="row">
    <div class="col-lg-12">
      <div class="panel panel-primary">
        <div class="panel-heading"><i class="fa fa-clock-o fa-fw"></i> Time and date</div>
        <!-- /.panel-heading -->
          <div class="panel-body">
  	        <p><?php $status->showMessages(); ?></p>
            <div class="row">
              <div class="col-md-6">
                <div class="panel panel-default">
                  <div class="panel-body">
                    <form role="form" action="?page=time_conf" method="POST">
                      <?php CSRFToken() ?>
                      <h4>Camera Date</h4>
                      <div class="info-item">Current date</div> <?php echo $curr_day[0]."-".$curr_month[0]."-".$curr_year[0] ?></br>
                      <div class="row">
                        <div class="form-group col-md-4">
                          <label for="code">New date</label>
                          <?php 
                            SelectorOptions('setday', $arrDay, $curr_day[0]);
                            SelectorOptions('setmonth', $arrMonth, $curr_month[0]);
                            SelectorOptions('setyear', $arrYear, $curr_year[0]); 
                          ?>
                        </div>
                      </div>
                      <input type="submit" class="btn btn-outline btn-primary" name="setdate" value="Set the date" />
                    </form>
                  </div><!-- /.panel-body -->
              </div><!-- /.panel-default -->
              </div><!-- /.col-md-6 -->
            </div><!-- /.row -->

            <div class="row">
              <div class="col-md-6">
                <div class="panel panel-default">
                  <div class="panel-body">
                    <form role="form" action="?page=time_conf" method="POST">
                      <?php CSRFToken() ?>
                      <h4>Camera Time</h4>
                      <div class="info-item">Current time</div> <?php echo $curr_hour[0].":".$curr_minute[0] ?></br>
                      <div class="row">
                        <div class="form-group col-md-4">
                          <label for="code">New time</label>
                          <?php 
                            SelectorOptions('sethour', $arrHour, $curr_hour[0]);
                            SelectorOptions('setminute', $arrMinute, $curr_minute[0]); 
                          ?>
                        </div>
                      </div>
                      <input type="submit" class="btn btn-outline btn-primary" name="settime" value="Set the time" />
                    </form>
                  </div><!-- /.panel-body -->
              </div><!-- /.panel-default -->
              </div><!-- /.col-md-6 -->
            </div><!-- /.row -->


          </div><!-- /.panel-body -->
          <div class="panel-footer"></div>
        </div><!-- /.panel-primary -->
    </div><!-- /.col-lg-12 -->
  </div><!-- /.row -->
<?php 
}

function SetDate($status) {

  $newday = $_POST['setday'];
  $newmonth = $_POST['setmonth'];
  $newyear = $_POST['setyear'];

  $newdate = $newday."-".$newmonth."-".$newyear;
  exec ("sudo date --set='".$newdate."'", $output, $return);

  if( $return == 0 ) {
    $status->addMessage('New system date has been saved', 'success');
    exec ("sudo hwclock -w", $output, $return);
    if( $return == 0 ) {
      $status->addMessage('New date has been written to the RTC', 'success');
    } else {
      $status->addMessage('Unable to write the new date to the RTC', 'danger');
      return false;
    }
  } else {
    $status->addMessage('Unable to save the new system date', 'danger');
    return false;
  }

  return true;
}

function SetTime($status) {

  $newhour = $_POST['sethour'];
  $newminute = $_POST['setminute'];
  $newday = $_POST['setday'];
  $newmonth = $_POST['setmonth'];
  $newyear = $_POST['setyear'];

  // $newtime = $newhour.":".$newminute;
  // exec ("sudo date --set='".$newtime."'", $output, $return);

  // if( $return == 0 ) {
  //   $status->addMessage('New system time has been saved', 'success');
  //   exec ("sudo hwclock -w", $output, $return);
  //   if( $return == 0 ) {
  //     $status->addMessage('New time has been written to the RTC', 'success');
  //   } else {
  //     $status->addMessage('Unable to write the new time to the RTC', 'danger');
  //     return false;
  //   }
  // } else {
  //   $status->addMessage('Unable to save the new system time', 'danger');
  //   return false;
  // }


  $newtime = $newday."-".$newmonth."-".$newyear." ".$newhour.":".$newminute;
  exec ("sudo hwclock --set --date='".$newtime."'", $output, $return);

  if( $return == 0 ) {
    $status->addMessage('New time has been written to the RTC', 'success');
    exec ("sudo hwclock --r", $output, $return);
    if( $return == 0 ) {
      $status->addMessage('New time has been written to the RTC', 'success');
    } else {
      $status->addMessage('Unable to write the RTC time to the system', 'danger');
    }
  } else {
    $status->addMessage('Unable to write the new time to the RTC', 'danger');
    return false;
  }

  return true;
}


?>


    