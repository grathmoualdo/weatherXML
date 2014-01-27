<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mbds="http://www.xml.pastorelly.com">
	<xsl:output method="html" encoding="UTF-8" indent="yes" />

	<xsl:variable name="youngestClient"
		select="//Client[xs:date(@DateOfBirth) = max(for $i in //Client return xs:date($i/@DateOfBirth))]" />
	<xsl:variable name="oldestClient"
		select="//Client[xs:date(@DateOfBirth) = min(for $i in //Client return xs:date($i/@DateOfBirth))]" />
	<xsl:variable name="richestClient"
		select="//Client[sum(for $i in .//AccountRef/@Ref return //Accounts/*[@Number=$i]/@Balance) = max(for $i in //Client return sum(for $j in $i//AccountRef/@Ref return //Accounts/*[@Number=$j]/@Balance))]" />

	<xsl:function name="mbds:age" as="xs:integer">
		<xsl:param name="dateOfBirth" as="xs:date" />
		<xsl:variable name="today" select="current-date()" />
		<xsl:choose>
			<xsl:when test="$dateOfBirth > $today">
				<xsl:value-of select="0" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="intermediateResult" select="year-from-date($today) - year-from-date($dateOfBirth)" />
				<xsl:choose>
					<xsl:when test="(month-from-date($dateOfBirth) > month-from-date($today)) or
						((month-from-date($dateOfBirth) = month-from-date($today)) and ((day-from-date($dateOfBirth) > day-from-date($today))))">
						<xsl:value-of select="$intermediateResult - 1" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$intermediateResult" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:template name="DisplayAge">
		<xsl:param name="dateOfBirth" />
		<xsl:text> (</xsl:text>
		<xsl:value-of select="mbds:age(xs:date($dateOfBirth))" />
		<xsl:text>)</xsl:text>
	</xsl:template>

	<xsl:template name="TransformAccounts">
		<xsl:param name="border" />
		<xsl:param name="nextTarget" />
		<xsl:param name="sortKey" />
		<xsl:param name="sortOrder" />
		<table border="{$border}">
			<tr><th>Number</th><th>Type</th><th>Balance</th></tr>
			<xsl:apply-templates select="$nextTarget">
				<xsl:sort select="./@*[name()=$sortKey]" order="{$sortOrder}" data-type="number" />
			</xsl:apply-templates>			
		</table>
	</xsl:template>
	
	<xsl:template match="/Bank">
		<html>
			<head>
				<title>Statistics and details about the bank</title>
			</head>
			<body align="center">
				<h1>Statistics</h1>
				<table border="3">
					<tr>
						<td>Number of accounts:</td>
						<td align="right"><xsl:value-of select="count(Accounts/*)" /></td>
					</tr>
					<tr>
						<td>Number of clients:</td>
						<td align="right"><xsl:value-of select="count(//Client)" /></td>
					</tr>
					<tr>
						<td>Total wealth:</td>
						<td align="right"><xsl:value-of select="format-number(sum(//Accounts/*/@Balance), '#.00')" /></td>
					</tr>
					<tr>
						<td>Average account balance:</td>
						<td align="right"><xsl:value-of select="format-number(avg(//Accounts/*/@Balance), '#.00')" /></td>
					</tr>
					<tr>
						<td>Average client wealth:</td>
						<td align="right"><xsl:value-of select="format-number(avg(for $i in //Client return sum(for $j in $i//AccountRef/@Ref return //Accounts/*[@Number=$j]/@Balance)), '#.00')" /></td>
					</tr>
					<tr>
						<td>Youngest client:</td>
						<td>
							<xsl:value-of select="$youngestClient/@Forename" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="$youngestClient/@Surname" />
							<xsl:call-template name="DisplayAge">
								<xsl:with-param name="dateOfBirth" select="$youngestClient/@DateOfBirth" />
							</xsl:call-template>
						</td>
					</tr>
					<tr>
						<td>Oldest client:</td>
						<td>
							<xsl:value-of select="$oldestClient/@Forename" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="$oldestClient/@Surname" />
							<xsl:call-template name="DisplayAge">
								<xsl:with-param name="dateOfBirth" select="$oldestClient/@DateOfBirth" />
							</xsl:call-template>
						</td>
					</tr>
					<tr>
						<td>Richest client:</td>
						<td>
							<xsl:value-of select="$richestClient/@Forename" />
							<xsl:text> </xsl:text>
							<xsl:value-of select="$richestClient/@Surname" />
							<xsl:call-template name="DisplayAge">
								<xsl:with-param name="dateOfBirth" select="$richestClient/@DateOfBirth" />
							</xsl:call-template>
						</td>
					</tr>
				</table>
				<hr />
				<h1>Details</h1>
				<h2>Account<xsl:if test="count(Accounts/*) &gt; 1">s</xsl:if></h2>
				<ul>
					<xsl:for-each-group select="Accounts/*" group-by="./name()">
						<li><h3><xsl:value-of select="current-grouping-key()" /></h3>
							<xsl:call-template name="TransformAccounts">
								<xsl:with-param name="border">3</xsl:with-param>
								<xsl:with-param name="nextTarget" select="current-group()" />
								<xsl:with-param name="sortKey">Number</xsl:with-param>
								<xsl:with-param name="sortOrder">ascending</xsl:with-param>
							</xsl:call-template>
						</li>
					</xsl:for-each-group>
				</ul>
				<h2>Client<xsl:if test="count(Clients/*) &gt; 1">s</xsl:if></h2>
				<ol>
					<xsl:apply-templates select="Clients/*" />
				</ol>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="Accounts/*">
		<tr>
			<td><xsl:value-of select="@Number" /></td>
			<td><xsl:value-of select="./name()" /></td>
			<td align="right"><xsl:value-of select="@Balance" /></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="Client">
		<li>
			<h3>
				<xsl:value-of select="@Forename" /><xsl:text> </xsl:text><xsl:value-of select="@Surname" />
				<xsl:call-template name="DisplayAge">
					<xsl:with-param name="dateOfBirth" select="@DateOfBirth" />
				</xsl:call-template>
			</h3>
			<ul>
				<li>Wealth
					<table border="1">
						<tr>
							<td>
								<xsl:value-of select="format-number(sum(for $i in .//AccountRef/@Ref return //Accounts/*[@Number=$i]/@Balance), '#.00')" />
							</td>
						</tr>
					</table>
				</li>
				<li>Address<xsl:if test="count(Addresses/*) &gt; 1">es</xsl:if>
					<table border="1">
						<xsl:apply-templates select="Addresses/*" />
					</table>
				</li>
				<li>Account<xsl:if test="count(AccountRefs/*) &gt; 1">s</xsl:if>
					<xsl:call-template name="TransformAccounts">
						<xsl:with-param name="border">1</xsl:with-param>
						<xsl:with-param name="nextTarget" select="//Accounts/*[contains(string-join(current()//AccountRef/@Ref, ','), @Number)]" />
						<xsl:with-param name="sortKey">Balance</xsl:with-param>
						<xsl:with-param name="sortOrder">descending</xsl:with-param>
					</xsl:call-template>
				</li>
			</ul>
		</li>
	</xsl:template>

	<xsl:template match="Address">
		<tr><td><xsl:value-of select="string-join(*,' -,- ')" /></td></tr>
	</xsl:template>
	
</xsl:stylesheet>