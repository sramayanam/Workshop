(function() {


}).call(this);


function fbShare(url){
	var shareURL = 'https://www.facebook.com/sharer/sharer.php?u='+url+'';
	window.open(shareURL, "", "width=600, height=600");
	return false;
}


function linkedinShare(url, title, description, src){
	var shareURL = 'https://www.linkedin.com/shareArticle?mini=true&url='+url+'&title='+title+'&summary='+description+'&source='+src;
	window.open(shareURL, "", "width=600, height=600");
	return false;
}

function twitterShare(url){
	var shareURL = 'https://twitter.com/home?status='+'Take a look at this article: '+url;
	window.open(shareURL, "", "width=600, height=600");
	return false;
}

function emailShare(url){
	var shareURL = "mailto:"
             + "?subject=" + escape("Take a look at this article:")
             + "&body=" + escape("I want to share this article with you: " + url);
	window.location.href = shareURL;
	return false;	
}
