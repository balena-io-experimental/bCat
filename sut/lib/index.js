const rp = require('request-promise');
const fs = require('fs')
const retry = require('async-retry');
const bluebird = require('bluebird');
const looksSame = require('looks-same');

const browserBlockUrl = `http://localhost:5011`

const main = async () => {
    // wait until browser block is up
    await bluebird.delay(1000*15);
    await retry(
        async () => {
          // if anything throws, we retry
          let res = await rp.get(`${browserBlockUrl}/ping`);
          console.log(res)
        
          if (res !== 'ok') {
            // don't retry upon 403
            throw new Error ('Browser block not ready')
          }
        },
        {
          retries: 20,
        }
    );

    let url = await rp.get(`${browserBlockUrl}/url`);
    console.log(url)

    //const targetUrl = `https://www.balena.io/`
    console.log(`Setting target URL`)
    await rp.post({
        uri: `${browserBlockUrl}/url`, 
        body: {
            url: 'www.balena.io'
        },
        json: true
    })

    console.log(`Checking URL is set`)

    url = await rp.get(`${browserBlockUrl}/url`);
    console.log(url)


    // wait 30s for page to load
    await bluebird.delay(1000*15);

    console.log(`Screenshotting...`)
    // get a screenshot
    let screenshot = await rp.get(`${browserBlockUrl}/screenshot`, 
    {
        uri: url,
        method: "GET",
        encoding: null, // it also works with encoding: null
        headers: {
            "Content-type": "image/png"
        }
    })
    
    await bluebird.delay(1000*15);
    let writestream = fs.createWriteStream(`/data/result.png`);
    writestream.write(screenshot)
    writestream.on('finish', () => {
        console.log(`Stream closed, screenshot should be captured`);
    });
    writestream.end()


    console.log(`Checking screenshot against reference image...`);
    let pass = await new Promise((resolve, reject) => {
        looksSame('/data/result.png', '/data/testImage.png', function(err, result){
            console.log(err)
            console.log(result)
            if(result.equal){
                console.log(`Images match - passed!`);
                resolve(true)
            } else{
                console.log(`Images don't match - failed!`);
                resolve(false)
            }
        })
    })

    if(pass){
        process.exitCode = 0;
        process.exit()
    } else{
        process.exitCode = 1;
        process.exit()
    }
};

main();