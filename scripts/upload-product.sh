#!/bin/bash -e

function upload_product_to_om () {
    local product_path=${1:?Need Product Path}
    
    om upload-product --product $product_path

}

upload_product_to_om $@




