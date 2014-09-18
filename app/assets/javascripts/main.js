// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require bootstrap
//= require Autolinker
//= require timeago
//= require snap_svg-min
//= require modernizr_custom
//= require classie
//= require notificationFx
//= require dataTables
//= require dataTables_bootstrap
//= require_directory ./main
//= require slick


/**
 * Timeago is a jQuery plugin that makes it easy to support automatically
 * updating fuzzy timestamps (e.g. "4 minutes ago" or "about 1 day ago").
 *
 * @name timeago
 * @version 1.4.1
 * @requires jQuery v1.2.3+
 * @author Ryan McGeary
 * @license MIT License - http://www.opensource.org/licenses/mit-license.php
 *
 * For usage and examples, visit:
 * http://timeago.yarp.com/
 *
 * Copyright (c) 2008-2013, Ryan McGeary (ryan -[at]- mcgeary [*dot*] org)
 */

function addNotification(type, message, name, icon) {
//    icons = {error: 'exclamation-circle', success: 'check-circle', alert: 'info-circle', notice: 'info-circle'}
    $.growl({
        message: '<div class="notif-left"><i class="fa fa-'+icon+' fa-fw"></i></div><div class="notif-right"><div class="fz16">'+name+'</div><div class="fz12-5">'+message+'</div></div>'
    },{
        type: "notif",
        placement: {
            from: "bottom",
            align: "right"
        },
        template: '<div data-growl="container" class="alert" role="alert">' +
            '<button type="button" class="close" data-growl="dismiss">' +
                '<span aria-hidden="true">×</span>' +
                '<span class="sr-only">Close</span>' +
            '</button>' +
            '<div data-growl="message" class="notif-wrapper"></div>' +
        '</div>'
    });
}
