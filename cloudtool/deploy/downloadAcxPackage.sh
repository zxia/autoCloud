downloadAndExtract() {
    local url="$1"
    local destination="$2"
    local SUCCESS_FILE=${downloadDir}/transaction.log

    [ -d "${destination}" ] || mkdir -p "${destination}"

    # Extract version and build from URL
    local appName=$(echo "$url" | awk -F/ '{ print $6 }')
    local version=$(echo "$url" | awk -F/ '{ print $8 }')
    local minVersion=$(echo "$url" | awk -F/ '{ print $9 }')
    local filename=${appName}-${version}-${minVersion}.tar.gz

    # Download tar.gz file
    if  curl -L "$url/$filename" -o "$destination/$filename"; then
        echo "Error downloading file from $url"
    fi

    # Extract tar.gz file
    if ! tar -xzvf "$destination/$filename" -C "$destination"; then
       curl -L "$url/${appName}-bin-${version}-${minVersion}.tar.gz" -o "$destination/$filename" || return 2
       if ! tar -xzvf "$destination/$filename" -C "$destination"; then
          echo "Error extracting file $filename to $destination"
          return 2
       fi
    fi


    # Clean up downloaded tar.gz file
    rm -rf "$destination/$filename"

    # Record successful URL to file
    printf "${appName}\t${version}\t${minVersion}\n"  >> "$destination/info.txt"
    echo "$url" >> "$SUCCESS_FILE"
}

processUri() {
    local uri="$1"
    local urlFile="app-url-http.txt"
    local downloadDir="$2"
    local SUCCESS_FILE=${downloadDir}/transaction.log
    # Check for successful URLs file
    if [ -e "$SUCCESS_FILE" ]; then
        echo "Found existing successful URLs file: $SUCCESS_FILE"
        echo "Skipping already successful URLs:"
        cat "$SUCCESS_FILE"
        echo
    fi

    # Download app-url-http.txt
    if ! curl -L "${uri}/cfg/${urlFile}" -o "$urlFile"; then
        echo "Error downloading app-url-http.txt from $uri"
        return 3
    fi

    # Read each line from app-url-http.txt and process
    while IFS= read -r line; do
        # Skip if URL is already successful
        if grep -Fxq "$line" "$SUCCESS_FILE"; then
            echo "Skipping already successful URL: $line"
            continue
        fi

        # Skip empty lines
        if [ -n "$line" ]; then
            if [[ $line == *"/dist/acx/"* || $line == *"/dist/message/"* ]];then
              # Call function to download and extract
              if ! downloadAndExtract "$line" "$downloadDir"; then
                  echo "Error processing URL: $line"
                  return 4
              fi
           fi
        fi
    done < "$urlFile"

    # Clean up
    rm -rf "$urlFile"
}

function buildAcxImage() {
  local serviceName=$1
  local version=$2
  local minVersion=$3
  local HARBOR=gmct.storage.com/library
  local fromPath=$4

  local image=${HARBOR}/${serviceName}:${version}-${minVersion}
  local localPath=/home/opuser/docker/${serviceName}

  [ -d ${localPath}/files ] || mkdir -p ${localPath}/files

  rsync -ar ${fromPath}/${serviceName}-${version}/bin/${serviceName}.jar  ${localPath}/files/ || rsync -ar ${fromPath}/${serviceName}-bin-${version}/bin/${serviceName}.jar

  echo "FROM eclipse-temurin:11.0.18_10-jdk" >${localPath}/Dockerfile
  echo "COPY files/${serviceName}.jar /opt/acx/${serviceName}/bin/" >>${localPath}/Dockerfile

  docker build -t ${image} ${localPath}  || return $?
  docker push ${image}  || return $?

}

function buildAcxImages() {
  local packageDir=$1
  local transactionFile=${packageDir}/build.log

  while IFS= read -r line; do
      # Skip if URL is already successful
      if grep -Fxq "$line" "$transactionFile"; then
          echo "Skipping already successful images build: $line"
          continue
      fi

      # Skip empty lines
      if [ -n "$line" ]; then
             # Call function to download and extract
            if ! buildAcxImage $line "$packageDir"; then
                echo "Error processing URL: $line"
                return 4
            fi
            echo $line >> ${transactionFile}
      fi
    done < "${packageDir}/info.txt"
}

function testProcessUri() {
    processUri "http://10.0.35.17/dist/acx/ac-all-build/ac6.7.9/dev/1035"  /root/app/1035
    buildAcxImages  /root/app/1035
}