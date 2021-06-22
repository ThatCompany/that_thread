var orig_showIssueHistory = showIssueHistory;

showIssueHistory = function(journal, url) {
    var ret = orig_showIssueHistory.apply(this, arguments);

    tab_content = $('#tab-content-history');
    if (journal == 'notes') {
        tab_content.addClass('threaded');
        tab_content.css('display', 'block');
    } else {
        tab_content.removeClass('threaded');
        tab_content.css('display', 'grid');
    }
    if (journal == 'properties') {
        tab_content.find('.journal .thread-links').hide();
    } else {
        tab_content.find('.journal .thread-links').show();
    }

    return ret;
}
