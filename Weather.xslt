<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ms="urn:schemas-microsoft-com:xslt" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<!--<xsl:output method="html" encoding="UTF-8" indent="yes"/>-->
	<xsl:strip-space elements="*"/>
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
	
<!--	<xsl:template match="/ForecastReturn">
		<html>
				<head>
					<title>Weather of <xsl:value-of select="City"/></title>
				</head>
				<body>
					<h1>Weather of <xsl:value-of select="City"/> (<xsl:value-of select="State"/>)</h1>
					<xsl:apply-templates select="ForecastResult/*"/>
				</body>
		</html>
	</xsl:template>-->
	
	<xsl:template match="@*|node()">
		<!--<li>	
			<ul>-->
				<xsl:copy>
					<xsl:apply-templates/>
				</xsl:copy>
			<!--</ul>
		</li>-->
	</xsl:template>

	<xsl:template match="Forecast">
		<xsl:copy>
			<xsl:apply-templates/>
			<xsl:copy-of select="document('ImagesWeather.xml')/ArrayOfWeatherDescription/WeatherDescription[WeatherID=./WeatherID]"/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>
