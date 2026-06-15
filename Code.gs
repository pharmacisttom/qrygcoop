/**
 * GAS Backend สำหรับทำหน้าที่ "LINE Notification Relay"
 * รับ HTTP POST แบบ no-cors จาก GitHub Pages เพื่อยิง LINE Push Message
 */

const LINE_ACCESS_TOKEN = 'bVC7EPnCFmKsOE8smCV7Idj4mT0swlZ0kOBKq8RMh7lCB1V5s5J2Td3IUHx65jYc4S9TTLsQX1xzZuGT5+Spa6ZLFZ5rWHtd/NJKe+WhyPD8HuiD/SmF8YTFJSyULqMBTKkroTw7gTt3c29tluEvlQdB04t89/1O/w1cDnyilFU=';
const REVIEW_LIFF_URL = 'https://pharmacisttom.github.io/qrygcoop/review.html'; // URL ของหน้าประเมิน

function doPost(e) {
  try {
    const data = JSON.parse(e.postData.contents);
    
    // แจ้งเตือนจองคิวใหม่สำเร็จ
    if (data.action === 'notify_new_queue') {
      const msg = `ยืนยันการจองคิวสำเร็จ!\nหมายเลขคิว: ${data.queueNum}\nบริการ: ${data.service}\nเวลานัดหมาย: ${data.datetime}`;
      sendLinePushMessage(data.userId, msg);
    }
    
    // แจ้งเตือนเมื่อ Admin อัปเดตสถานะ (เรียกคิว / เสร็จสิ้น)
    if (data.action === 'notify_status_update') {
      if (data.status === 'CALLING') {
        sendLinePushMessage(data.userId, `ถึงคิวของคุณแล้วครับ!\nกรุณาติดต่อที่ช่องบริการหมายเลข 1`);
      } else if (data.status === 'DONE') {
        const flex = getReviewFlexMessage(data.queueId);
        sendLinePushMessage(data.userId, "ขอบคุณที่ใช้บริการครับ รบกวนช่วยประเมินความพึงพอใจให้เราหน่อยนะครับ", flex);
      }
    }
    
    return ContentService.createTextOutput(JSON.stringify({ status: "success" })).setMimeType(ContentService.MimeType.JSON);
    
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({ error: err.message })).setMimeType(ContentService.MimeType.JSON);
  }
}

// อนุญาตให้ยิงแบบ GET เพื่อทดสอบการทำงานเบื้องต้นได้
function doGet(e) {
  return ContentService.createTextOutput("GAS Notification Relay is Active!");
}

function sendLinePushMessage(userId, text, flexPayload = null) {
  const payload = {
    to: userId,
    messages: []
  };
  
  if (flexPayload) payload.messages.push(flexPayload);
  else payload.messages.push({ type: 'text', text: text });

  const options = {
    method: 'post',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + LINE_ACCESS_TOKEN
    },
    payload: JSON.stringify(payload)
  };

  UrlFetchApp.fetch('https://api.line.me/v2/bot/message/push', options);
}

function getReviewFlexMessage(queueId) {
  // แนบ Parameter queue_id ไปด้วย เพื่อให้หน้า review.html รู้ว่าประเมินของคิวไหน
  const reviewUrlWithParam = REVIEW_LIFF_URL + '?queue_id=' + queueId;
  
  return {
    "type": "flex",
    "altText": "แบบประเมินความพึงพอใจ",
    "contents": {
      "type": "bubble",
      "body": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          { "type": "text", "text": "📝 แบบประเมินความพึงพอใจ", "weight": "bold", "size": "lg", "color": "#0d9488" },
          { "type": "separator", "margin": "xl" },
          { "type": "text", "text": "คลิกปุ่มด้านล่างเพื่อประเมินความพึงพอใจการใช้บริการในวันนี้", "wrap": true, "margin": "md" }
        ]
      },
      "footer": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "button",
            "style": "primary",
            "action": { "type": "uri", "label": "ทำแบบประเมิน", "uri": reviewUrlWithParam },
            "color": "#14b8a6"
          }
        ]
      }
    }
  };
}
