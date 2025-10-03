const {onDocumentCreated} = require('firebase-functions/v2/firestore');
const {onCall} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const sgMail = require('@sendgrid/mail');

// Initialize Firebase Admin
admin.initializeApp();

/**
 * HTTP Callable function - THIS IS THE ONE YOUR HTML CALLS
 */
exports.sendQuoteNotification = onCall({
    region: 'us-central1',
    cors: true
}, async (request) => {
    try {
        const quoteData = request.data;
        console.log('📧 sendQuoteNotification called for:', quoteData?.email);
        
        if (!quoteData || !quoteData.email || !quoteData.firstName) {
            console.error('❌ Missing required quote data:', {
                hasQuoteData: !!quoteData,
                hasEmail: !!quoteData?.email,
                hasFirstName: !!quoteData?.firstName
            });
            throw new Error('Missing required quote data');
        }

        // Use process.env.SENDGRID_API_KEY only
        const sendgridApiKey = process.env.SENDGRID_API_KEY;
        
        console.log('🔑 SendGrid API key check:', {
            hasKey: !!sendgridApiKey,
            keyLength: sendgridApiKey ? sendgridApiKey.length : 0,
            keyPrefix: sendgridApiKey ? sendgridApiKey.substring(0, 7) : 'none'
        });

        if (!sendgridApiKey) {
            console.error('❌ SENDGRID_API_KEY not found in process.env');
            throw new Error('SendGrid API key not configured in environment variables');
        }

        // Initialize SendGrid
        sgMail.setApiKey(sendgridApiKey);
        console.log('✅ SendGrid initialized');

        // Generate email content
        const emailContent = await generateEmailContent(quoteData);
        const textContent = generateTextContent(quoteData);
        const customerEmailContent = generateCustomerEmail(quoteData);
        const customerTextContent = generateCustomerTextEmail(quoteData);

        const fromEmail = 'info@building-group.co.uk';
        
        // Email 1: Send detailed quote to company
        const companyMsg = {
            to: 'info@building-group.co.uk',
            from: fromEmail,
            replyTo: quoteData.email,
            subject: `🔨 New Quote Request - ${quoteData.quoteId} - ${quoteData.firstName} ${quoteData.lastName}`,
            html: emailContent,
            text: textContent
        };

        // Email 2: Send confirmation to customer
        const customerMsg = {
            to: quoteData.email,
            from: fromEmail,
            subject: 'Thank you for your quote request - Building Group',
            html: customerEmailContent,
            text: customerTextContent
        };

        console.log('📤 Sending emails to:', {
            company: companyMsg.to,
            customer: customerMsg.to
        });

        // Send both emails
        const [companyResult, customerResult] = await Promise.all([
            sgMail.send(companyMsg),
            sgMail.send(customerMsg)
        ]);

        console.log('✅ Both emails sent successfully!', {
            companyStatus: companyResult[0].statusCode,
            customerStatus: customerResult[0].statusCode
        });

        return {
            success: true,
            message: 'Emails sent successfully',
            companyStatus: companyResult[0].statusCode,
            customerStatus: customerResult[0].statusCode
        };

    } catch (error) {
        console.error('❌ sendQuoteNotification error:', {
            message: error.message,
            code: error.code,
            response: error.response?.body || 'no response body'
        });
        throw new Error(`Email sending failed: ${error.message}`);
    }
});

exports.sendSupportNotification = onCall({ region: 'us-central1', cors: true }, async (request) => {
  try {
    const data = request.data || {};
    if (!data.email || !data.firstName || !data.message) {
      throw new Error('Missing required fields: email, firstName, message');
    }

    const sendgridApiKey = process.env.SENDGRID_API_KEY;
    if (!sendgridApiKey) throw new Error('SendGrid API key not configured');

    sgMail.setApiKey(sendgridApiKey);

    const fromEmail = 'info@building-group.co.uk';
    const supportId = data.supportId || `SUP-${Date.now()}`;

    const safe = (s) => (s || '').toString();

    // Company email
    const companyHtml = `
      <h2>New Support Message</h2>
      <p><strong>Support ID:</strong> ${supportId}</p>
      <p><strong>Name:</strong> ${safe(data.firstName)} ${safe(data.lastName || '')}</p>
      <p><strong>Email:</strong> ${safe(data.email)}</p>
      <p><strong>Phone:</strong> ${safe(data.phone || 'N/A')}</p>
      <p><strong>Subject:</strong> ${safe(data.subject || 'N/A')}</p>
      <p><strong>Message:</strong></p>
      <div style="white-space:pre-wrap">${safe(data.message)}</div>
      <hr/>
      <p><small>Source: ${safe(data.source || '')}</small></p>
      <p><small>Timestamp: ${safe(data.timestamp || new Date().toISOString())}</small></p>
    `;
    const companyText = `New Support Message
Support ID: ${supportId}
Name: ${safe(data.firstName)} ${safe(data.lastName || '')}
Email: ${safe(data.email)}
Phone: ${safe(data.phone || 'N/A')}
Subject: ${safe(data.subject || 'N/A')}
Message:
${safe(data.message)}
Source: ${safe(data.source || '')}
Timestamp: ${safe(data.timestamp || new Date().toISOString())}
`;

    const companyMsg = {
      to: 'info@building-group.co.uk',
      from: fromEmail,
      replyTo: data.email,
      subject: `New Support Message - ${supportId} - ${safe(data.firstName)} ${safe(data.lastName || '')}`,
      html: companyHtml,
      text: companyText
    };

    // Customer confirmation
    const customerHtml = `
      <h2>Thank you for contacting Building Group</h2>
      <p>Hi ${safe(data.firstName)},</p>
      <p>We've received your message and our team will be in touch shortly.</p>
      <p><strong>Support ID:</strong> ${supportId}</p>
      <p><strong>Subject:</strong> ${safe(data.subject || 'N/A')}</p>
      <p><strong>Your message:</strong></p>
      <div style="white-space:pre-wrap">${safe(data.message)}</div>
      <hr/>
      <p><strong>Need to speak now?</strong></p>
      <p>Head Office: +44 161 524 0819<br/>Emergency Contact: +44 7446 695 686</p>
      <p>Kind regards,<br/>Building Group</p>
    `;
    const customerText = `Thank you for contacting Building Group

Hi ${safe(data.firstName)},

We've received your message and will be in touch shortly.

Support ID: ${supportId}
Subject: ${safe(data.subject || 'N/A')}
Your message:
${safe(data.message)}

Head Office: +44 161 524 0819
Emergency Contact: +44 7446 695 686

Kind regards,
Building Group
`;

    await Promise.all([
      sgMail.send(companyMsg),
      sgMail.send({ to: data.email, from: fromEmail, subject: `We received your message - ${supportId}`, html: customerHtml, text: customerText })
    ]);

    return { success: true, supportId };
  } catch (err) {
    console.error('sendSupportNotification error:', err?.message, err?.response?.body);
    throw new Error(`Support email sending failed: ${err.message}`);
  }
});

// Replace the existing sendContactReply function with this v2 version:

exports.sendContactReply = onCall({
    region: 'us-central1',
    cors: true
}, async (request) => {
    try {
        // Check authentication
        if (!request.auth || request.auth.uid !== '2sBxzDGRO9Z3GDSTSF6DsRTkcDv2') {
            throw new Error('Only admin can send replies');
        }

        const { toEmail, toName, subject, message, originalMessage, contactId } = request.data;

        // Validate required fields
        if (!toEmail || !subject || !message) {
            throw new Error('Missing required fields: toEmail, subject, message');
        }

        // Get SendGrid API key
        const sendgridApiKey = process.env.SENDGRID_API_KEY;
        if (!sendgridApiKey) {
            throw new Error('SendGrid API key not configured');
        }

        // Initialize SendGrid
        sgMail.setApiKey(sendgridApiKey);

        const msg = {
            to: toEmail,
            from: {
                email: 'info@building-group.co.uk',
                name: 'Building Group'
            },
            subject: subject,
            text: message,
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                    <div style="background: #e74c3c; padding: 20px; text-align: center;">
                        <h1 style="color: white; margin: 0;">Building Group</h1>
                    </div>
                    <div style="padding: 30px; background: #f8f9fa;">
                        <p>${message.replace(/\n/g, '<br>')}</p>
                        
                        ${originalMessage ? `
                        <hr style="margin: 30px 0; border: none; border-top: 1px solid #dee2e6;">
                        
                        <div style="background: #ffffff; padding: 15px; border-radius: 8px; margin-top: 20px;">
                            <p style="color: #6c757d; margin: 0 0 10px 0;"><strong>Your original message:</strong></p>
                            <p style="color: #6c757d; margin: 0;">${originalMessage.replace(/\n/g, '<br>')}</p>
                        </div>
                        ` : ''}
                    </div>
                    <div style="background: #2c3e50; color: white; padding: 20px; text-align: center;">
                        <p style="margin: 0;">Building Group - Professional Building Services</p>
                        <p style="margin: 10px 0 0 0;">Manchester | Liverpool | Leeds | Cheshire</p>
                    </div>
                </div>
            `
        };

        console.log('📧 Sending contact reply to:', toEmail);

        const result = await sgMail.send(msg);
        
        console.log('✅ Contact reply sent successfully!', {
            status: result[0].statusCode,
            contactId: contactId
        });

        return {
            success: true,
            messageId: Date.now(),
            status: result[0].statusCode
        };

    } catch (error) {
        console.error('❌ sendContactReply error:', {
            message: error.message,
            code: error.code,
            response: error.response?.body || 'no response body'
        });
        throw new Error(`Failed to send reply: ${error.message}`);
    }
});
// ... rest of your functions stay exactly the same ...
function generateCustomerEmail(quoteData) {
    const formatDate = (isoString) => {
        return new Date(isoString).toLocaleString('en-GB', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    return `
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Thank you for your quote request</title>
        </head>
        <body style="font-family: 'Inter', Arial, sans-serif; line-height: 1.6; color: #333; background-color: #f8f9fa; margin: 0; padding: 0;">
            <div style="max-width: 600px; margin: 0 auto; background-color: white; box-shadow: 0 0 20px rgba(0,0,0,0.1);">
                <!-- Header -->
                <div style="background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; padding: 30px; text-align: center;">
                    <h1 style="margin: 0; font-size: 28px;">🔨 Building Group</h1>
                    <p style="margin: 10px 0 0 0; font-size: 16px;">Professional Construction Services</p>
                </div>
                
                <!-- Content -->
                <div style="padding: 30px;">
                    <h2 style="color: #e74c3c; margin-bottom: 20px;">Thank you for your quote request!</h2>
                    
                    <p style="font-size: 16px;">Dear ${quoteData.firstName},</p>
                    
                    <p>We have received your quote request and appreciate your interest in Building Group. Our expert team is reviewing your project details and will provide you with a comprehensive quote.</p>
                    
                    <div style="background: #f8f9fa; padding: 20px; border-left: 4px solid #e74c3c; margin: 25px 0; border-radius: 0 8px 8px 0;">
                        <h3 style="margin: 0 0 15px 0; color: #e74c3c;">Your Quote Details:</h3>
                        <p style="margin: 5px 0;"><strong>Reference Number:</strong> ${quoteData.quoteId}</p>
                        <p style="margin: 5px 0;"><strong>Service Requested:</strong> ${quoteData.serviceType.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}</p>
                        <p style="margin: 5px 0;"><strong>Property Location:</strong> ${quoteData.city}, ${quoteData.postcode}</p>
                        <p style="margin: 5px 0;"><strong>Submitted:</strong> ${formatDate(quoteData.timestamp)}</p>
                    </div>
                    
                    <h3 style="color: #2c3e50; margin-top: 30px;">What happens next?</h3>
                    <ol style="line-height: 2;">
                        <li>Our estimating team will carefully review your project requirements</li>
                        <li>We may contact you for any clarifications if needed</li>
                        <li>You'll receive a detailed quote via ${quoteData.preferredContact === 'email' ? 'email' : quoteData.preferredContact}</li>
                        <li>We'll schedule a site visit if required for accurate pricing</li>
                    </ol>
                    
                    <div style="background: #e8f5e8; padding: 20px; border-radius: 8px; margin: 25px 0;">
                        <h4 style="margin: 0 0 10px 0; color: #27ae60;">⏰ Response Time</h4>
                        <p style="margin: 0;"><strong>We aim to respond within 2 hours during business hours</strong><br>
                        Monday-Friday 8AM-6PM, Saturday 8AM-4PM</p>
                    </div>
                    
                    <div style="background: #fff3cd; padding: 20px; border-radius: 8px; margin: 25px 0;">
                        <h4 style="margin: 0 0 10px 0; color: #f39c12;">📞 Need immediate assistance?</h4>
                        <p style="margin: 0;">Call us directly at <strong>+44 7446 695 686</strong><br>
                        Our friendly team is here to help!</p>
                    </div>
                    
                    <p>Thank you for choosing Building Group. We look forward to working with you on your project!</p>
                    
                    <p style="margin-top: 30px;">Best regards,<br>
                    <strong>The Building Group Team</strong></p>
                </div>
                
                <!-- Footer -->
                <div style="background-color: #2c3e50; color: white; padding: 20px; text-align: center; font-size: 14px;">
                    <p style="margin: 0 0 10px 0;">Building Group - Professional Construction Services</p>
                    <p style="margin: 0; opacity: 0.8;">Manchester | Liverpool | Leeds | Cheshire</p>
                    <p style="margin: 10px 0; opacity: 0.8;">
                        <a href="https://www.building-group.co.uk" style="color: #f39c12; text-decoration: none;">www.building-group.co.uk</a> | 
                        <a href="mailto:info@building-group.co.uk" style="color: #f39c12; text-decoration: none;">info@building-group.co.uk</a>
                    </p>
                    <p style="margin: 10px 0 0 0; font-size: 12px; opacity: 0.6;">
                        Quote Reference: ${quoteData.quoteId}<br>
                        This is an automated confirmation email. Please keep this for your records.
                    </p>
                </div>
            </div>
        </body>
        </html>
    `;
}

function generateCustomerTextEmail(quoteData) {
    const formatDate = (isoString) => {
        return new Date(isoString).toLocaleString('en-GB', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    return `Dear ${quoteData.firstName},

Thank you for your quote request!

We have received your request and appreciate your interest in Building Group. Our expert team is reviewing your project details and will provide you with a comprehensive quote.

YOUR QUOTE DETAILS:
Reference Number: ${quoteData.quoteId}
Service Requested: ${quoteData.serviceType.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase())}
Property Location: ${quoteData.city}, ${quoteData.postcode}
Submitted: ${formatDate(quoteData.timestamp)}

WHAT HAPPENS NEXT?
1. Our estimating team will carefully review your project requirements
2. We may contact you for any clarifications if needed
3. You'll receive a detailed quote via ${quoteData.preferredContact === 'email' ? 'email' : quoteData.preferredContact}
4. We'll schedule a site visit if required for accurate pricing

RESPONSE TIME:
We aim to respond within 2 hours during business hours
Monday-Friday 8AM-6PM, Saturday 8AM-4PM

Need immediate assistance?
Call us directly at +44 7446 695 686

Thank you for choosing Building Group. We look forward to working with you on your project!

Best regards,
The Building Group Team

--
Building Group - Professional Construction Services
Manchester | Liverpool | Leeds | Cheshire
www.building-group.co.uk | info@building-group.co.uk

Quote Reference: ${quoteData.quoteId}
This is an automated confirmation email. Please keep this for your records.`;
}

function generateTextContent(quoteData) {
    const formatCurrency = (amount) => {
        if (amount >= 1000000) {
            return `£${(amount / 1000000).toFixed(1)}M`;
        } else if (amount >= 1000) {
            return `£${(amount / 1000).toFixed(0)}K`;
        } else {
            return `£${amount.toLocaleString()}`;
        }
    };

    const formatDate = (isoString) => {
        return new Date(isoString).toLocaleString('en-GB', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    let text = `
BUILDING GROUP - NEW QUOTE REQUEST
==================================

URGENT: New quote request received - ${quoteData.quoteId}
Submitted: ${formatDate(quoteData.timestamp)}

CUSTOMER DETAILS:
Name: ${quoteData.firstName} ${quoteData.lastName}
Email: ${quoteData.email}
Phone: ${quoteData.phone}
Preferred Contact: ${quoteData.preferredContact}

PROPERTY DETAILS:
Address: ${quoteData.address}
City: ${quoteData.city}
Postcode: ${quoteData.postcode}
Property Type: ${quoteData.propertyType || 'Not specified'}

PROJECT DETAILS:
Service Type: ${quoteData.serviceType}
Budget: ${formatCurrency(quoteData.budget)}
Timeline: ${quoteData.timeline || 'Not specified'}

Project Description:
${quoteData.projectDescription}

${quoteData.additionalInfo ? `Additional Information:\n${quoteData.additionalInfo}\n` : ''}

${quoteData.budgetNotes ? `Budget Notes:\n${quoteData.budgetNotes}\n` : ''}

FILES UPLOADED: ${quoteData.fileCount || 0}
${quoteData.files && quoteData.files.length > 0 ? 
    quoteData.files.map(file => `- ${file.name} (${(file.size / 1024 / 1024).toFixed(2)} MB): ${file.url}`).join('\n') : 
    'No files uploaded'
}

How they heard about us: ${quoteData.hearAbout || 'Not specified'}

TECHNICAL INFO:
IP: ${quoteData.ip}
Source: ${quoteData.source}

RESPOND WITHIN 2 HOURS DURING BUSINESS HOURS!

--
This email was automatically generated by the Building Group quote system.
Quote ID: ${quoteData.quoteId}
Timestamp: ${formatDate(quoteData.timestamp)}
`;

    return text;
}

async function generateEmailContent(quoteData) {
    const formatCurrency = (amount) => {
        if (amount >= 1000000) {
            return `£${(amount / 1000000).toFixed(1)}M`;
        } else if (amount >= 1000) {
            return `£${(amount / 1000).toFixed(0)}K`;
        } else {
            return `£${amount.toLocaleString()}`;
        }
    };

    const formatDate = (isoString) => {
        return new Date(isoString).toLocaleString('en-GB', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    };

    const serviceTypeLabels = {
        'new-house-building': 'New House Building',
        'house-renovations': 'House Renovations',
        'house-extensions': 'House Extensions',
        'loft-conversions': 'Loft Conversions',
        'kitchen-fitting': 'Kitchen Fitting',
        'bathroom-fitting': 'Bathroom Fitting',
        'full-rewire': 'Full House Rewiring',
        're-roofing': 'Re-Roofing',
        'groundworks': 'Groundworks & Foundations',
        'planning-permission': 'Planning Permission',
        'building-regulations': 'Building Regulations',
        'other': 'Other'
    };

    const timelineLabels = {
        'asap': 'As Soon As Possible',
        '1-3months': '1-3 Months',
        '3-6months': '3-6 Months',
        '6-12months': '6-12 Months',
        '12months+': '12+ Months',
        'flexible': 'Flexible'
    };

    const propertyTypeLabels = {
        'detached': 'Detached House',
        'semi-detached': 'Semi-Detached House',
        'terraced': 'Terraced House',
        'bungalow': 'Bungalow',
        'flat': 'Flat/Apartment',
        'commercial': 'Commercial Property',
        'other': 'Other'
    };

    const contactMethodLabels = {
        'email': 'Email',
        'phone': 'Phone Call',
        'text': 'Text Message',
        'any': 'Any Method'
    };

    const hearAboutLabels = {
        'google': 'Google Search',
        'social-media': 'Social Media',
        'recommendation': 'Recommendation',
        'previous-customer': 'Previous Customer',
        'local-advertising': 'Local Advertising',
        'other': 'Other'
    };

    // Generate file links HTML
    let fileLinksHtml = '';
    if (quoteData.files && quoteData.files.length > 0) {
        fileLinksHtml = `
            <div style="margin: 20px 0; padding: 15px; background-color: #f8f9fa; border-radius: 8px; border: 2px solid #3498db;">
                <h3 style="color: #3498db; margin: 0 0 15px 0; font-size: 18px;">📎 Uploaded Files (${quoteData.files.length})</h3>
                <div style="display: grid; gap: 10px;">
                    ${quoteData.files.map((file, index) => `
                        <div style="display: flex; align-items: center; padding: 10px; background-color: white; border-radius: 6px; border: 1px solid #dee2e6;">
                            <span style="background-color: #3498db; color: white; padding: 5px 10px; border-radius: 20px; font-size: 12px; font-weight: bold; margin-right: 10px;">${index + 1}</span>
                            <div style="flex-grow: 1;">
                                <a href="${file.url}" target="_blank" style="color: #3498db; text-decoration: none; font-weight: 600; font-size: 14px;">
                                    ${file.name}
                                </a>
                                <div style="font-size: 12px; color: #6c757d; margin-top: 2px;">
                                    ${(file.size / 1024 / 1024).toFixed(2)} MB • ${file.type || 'Unknown type'}
                                </div>
                            </div>
                            <a href="${file.url}" target="_blank" style="background-color: #27ae60; color: white; padding: 8px 12px; border-radius: 5px; text-decoration: none; font-size: 12px; font-weight: bold;">
                                DOWNLOAD
                            </a>
                        </div>
                    `).join('')}
                </div>
                <p style="font-size: 12px; color: #6c757d; margin: 15px 0 0 0; font-style: italic;">
                    💡 Tip: Right-click download links to save files directly to your computer.
                </p>
            </div>
        `;
    }

    return `
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>New Quote Request - ${quoteData.quoteId}</title>
        </head>
        <body style="font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #2c3e50; margin: 0; padding: 0; background-color: #f8f9fa;">
            <div style="max-width: 800px; margin: 0 auto; background-color: white; box-shadow: 0 0 20px rgba(0,0,0,0.1);">
                <!-- Header -->
                <div style="background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; padding: 30px; text-align: center;">
                    <h1 style="margin: 0; font-size: 28px; font-weight: 800;">🔨 Building Group</h1>
                    <p style="margin: 10px 0 0 0; font-size: 18px;">New Quote Request Received</p>
                </div>

                <!-- Alert Banner -->
                <div style="background-color: #f39c12; color: white; padding: 15px; text-align: center; font-weight: bold; font-size: 16px;">
                    ⚡ URGENT: NEW QUOTE REQUEST - RESPOND WITHIN 2 HOURS ⚡
                </div>

                <!-- Content -->
                <div style="padding: 30px;">
                    <!-- Quote Summary -->
                    <div style="background: linear-gradient(135deg, #e8f5e8, #d4edda); border-left: 5px solid #27ae60; padding: 25px; margin-bottom: 30px; border-radius: 0 10px 10px 0;">
                        <h2 style="color: #27ae60; margin: 0 0 15px 0; font-size: 22px;">📋 Quote Summary</h2>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                            <div>
                                <p style="margin: 8px 0;"><strong>Quote ID:</strong> <span style="font-family: monospace; background: #f8f9fa; padding: 2px 6px; border-radius: 4px;">${quoteData.quoteId}</span></p>
                                <p style="margin: 8px 0;"><strong>Submitted:</strong> ${formatDate(quoteData.timestamp)}</p>
                                <p style="margin: 8px 0;"><strong>Service:</strong> ${serviceTypeLabels[quoteData.serviceType] || quoteData.serviceType}</p>
                            </div>
                            <div>
                                <p style="margin: 8px 0;"><strong>Budget:</strong> <span style="font-size: 20px; color: #27ae60; font-weight: bold;">${formatCurrency(quoteData.budget)}</span></p>
                                <p style="margin: 8px 0;"><strong>Location:</strong> ${quoteData.city}, ${quoteData.postcode}</p>
                                <p style="margin: 8px 0;"><strong>Timeline:</strong> ${timelineLabels[quoteData.timeline] || quoteData.timeline || 'Not specified'}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Customer Information -->
                    <div style="margin-bottom: 30px;">
                        <h2 style="color: #e74c3c; border-bottom: 3px solid #e74c3c; padding-bottom: 10px; margin-bottom: 20px;">👤 Customer Information</h2>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                            <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
                                <h4 style="margin: 0 0 15px 0; color: #2c3e50;">Contact Details</h4>
                                <p style="margin: 8px 0;"><strong>Name:</strong> ${quoteData.firstName} ${quoteData.lastName}</p>
                                <p style="margin: 8px 0;"><strong>Email:</strong> <a href="mailto:${quoteData.email}" style="color: #3498db; text-decoration: none;">${quoteData.email}</a></p>
                                <p style="margin: 8px 0;"><strong>Phone:</strong> <a href="tel:${quoteData.phone}" style="color: #27ae60; text-decoration: none; font-weight: bold;">${quoteData.phone}</a></p>
                            </div>
                            <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
                                <h4 style="margin: 0 0 15px 0; color: #2c3e50;">Preferences</h4>
                                <p style="margin: 8px 0;"><strong>Preferred Contact:</strong> ${contactMethodLabels[quoteData.preferredContact] || quoteData.preferredContact}</p>
                                <p style="margin: 8px 0;"><strong>Heard About Us:</strong> ${hearAboutLabels[quoteData.hearAbout] || quoteData.hearAbout || 'Not specified'}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Property Details -->
                    <div style="margin-bottom: 30px;">
                        <h2 style="color: #e74c3c; border-bottom: 3px solid #e74c3c; padding-bottom: 10px; margin-bottom: 20px;">🏠 Property Details</h2>
                        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
                            <p style="margin: 10px 0;"><strong>Full Address:</strong> ${quoteData.address}</p>
                            <p style="margin: 10px 0;"><strong>City:</strong> ${quoteData.city}</p>
                            <p style="margin: 10px 0;"><strong>Postcode:</strong> ${quoteData.postcode}</p>
                            <p style="margin: 10px 0;"><strong>Property Type:</strong> ${propertyTypeLabels[quoteData.propertyType] || quoteData.propertyType || 'Not specified'}</p>
                        </div>
                    </div>

                    <!-- Project Details -->
                    <div style="margin-bottom: 30px;">
                        <h2 style="color: #e74c3c; border-bottom: 3px solid #e74c3c; padding-bottom: 10px; margin-bottom: 20px;">🔧 Project Details</h2>
                        <div style="background-color: #f8f9fa; padding: 20px; border-radius: 8px;">
                            <p style="margin: 10px 0;"><strong>Service Type:</strong> <span style="background-color: #3498db; color: white; padding: 4px 12px; border-radius: 15px; font-size: 14px;">${serviceTypeLabels[quoteData.serviceType] || quoteData.serviceType}</span></p>
                            <p style="margin: 10px 0;"><strong>Preferred Timeline:</strong> ${timelineLabels[quoteData.timeline] || quoteData.timeline || 'Not specified'}</p>
                        </div>
                        
                        <div style="margin: 20px 0;">
                            <h4 style="color: #2c3e50; margin-bottom: 10px;">📝 Project Description:</h4>
                            <div style="background-color: white; padding: 20px; border-radius: 8px; border-left: 4px solid #3498db; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                                ${quoteData.projectDescription.replace(/\n/g, '<br>')}
                            </div>
                        </div>

                        ${quoteData.additionalInfo ? `
                        <div style="margin: 20px 0;">
                            <h4 style="color: #2c3e50; margin-bottom: 10px;">ℹ️ Additional Information:</h4>
                            <div style="background-color: white; padding: 20px; border-radius: 8px; border-left: 4px solid #f39c12; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                                ${quoteData.additionalInfo.replace(/\n/g, '<br>')}
                            </div>
                        </div>
                        ` : ''}
                    </div>

                    <!-- Budget Information -->
                    <div style="margin-bottom: 30px;">
                        <h2 style="color: #e74c3c; border-bottom: 3px solid #e74c3c; padding-bottom: 10px; margin-bottom: 20px;">💰 Budget Information</h2>
                        <div style="background: linear-gradient(135deg, #d4edda, #c3e6cb); padding: 25px; border-radius: 10px; text-align: center;">
                            <p style="margin: 0 0 10px 0; font-size: 16px; color: #2c3e50;"><strong>Customer's Estimated Budget:</strong></p>
                            <p style="margin: 0; font-size: 36px; color: #27ae60; font-weight: bold;">${formatCurrency(quoteData.budget)}</p>
                        </div>
                        
                        ${quoteData.budgetNotes ? `
                        <div style="margin: 20px 0;">
                            <h4 style="color: #2c3e50; margin-bottom: 10px;">💡 Budget Notes:</h4>
                            <div style="background-color: white; padding: 20px; border-radius: 8px; border-left: 4px solid #27ae60; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                                ${quoteData.budgetNotes.replace(/\n/g, '<br>')}
                            </div>
                        </div>
                        ` : ''}
                    </div>

                    <!-- Files Section -->
                    ${fileLinksHtml}

                    <!-- Technical Details -->
                    <div style="margin-bottom: 30px; background-color: #f8f9fa; padding: 20px; border-radius: 8px; border-top: 3px solid #6c757d;">
                        <h3 style="color: #6c757d; margin: 0 0 15px 0; font-size: 16px;">🔍 Technical Details</h3>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px; font-size: 14px; color: #6c757d;">
                            <div>
                                <p style="margin: 5px 0;"><strong>IP Address:</strong> ${quoteData.ip}</p>
                                <p style="margin: 5px 0;"><strong>Source:</strong> ${quoteData.source}</p>
                            </div>
                            <div>
                                <p style="margin: 5px 0;"><strong>Submission Time:</strong> ${formatDate(quoteData.timestamp)}</p>
                                <p style="margin: 5px 0;"><strong>Files Count:</strong> ${quoteData.fileCount || 0}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Footer CTA -->
                    <div style="background: linear-gradient(135deg, #e74c3c, #c0392b); color: white; padding: 25px; border-radius: 10px; text-align: center;">
                        <h3 style="margin: 0 0 15px 0;">⏰ Response Time Target</h3>
                        <p style="margin: 0; font-size: 18px; font-weight: bold;">Respond within 2 hours during business hours!</p>
                        <p style="margin: 10px 0 0 0; font-size: 14px; opacity: 0.9;">Monday-Friday 8AM-6PM, Saturday 8AM-4PM</p>
                    </div>
                </div>

                <!-- Email Footer -->
                <div style="background-color: #2c3e50; color: white; padding: 20px; text-align: center; font-size: 12px;">
                    <p style="margin: 0;">This email was automatically generated by the Building Group quote system.</p>
                    <p style="margin: 5px 0 0 0; opacity: 0.8;">Quote ID: ${quoteData.quoteId} | Generated: ${formatDate(new Date().toISOString())}</p>
                </div>
            </div>
        </body>
        </html>
    `;
}
