<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" omit-xml-declaration="yes"/>

<xsl:template match="/">
	<script>{
		"title":
			<xsl:call-template name="escape-string">
				<xsl:with-param name="s" select="//entry/title/text()"/>
			</xsl:call-template>,
		"excerpt":
			<xsl:call-template name="escape-string">
				<xsl:with-param name="s" select="//entry[1]/desc/text()|//entry[1]/desc/*"/>
			</xsl:call-template>,
		"termSlugs": {
			"category": [
				<xsl:for-each select="//entry/category">
					<xsl:if test="position() &gt; 1"><xsl:text>,</xsl:text></xsl:if>
					<xsl:text>"</xsl:text>
					<xsl:value-of select="@slug"/>
					<xsl:text>"</xsl:text>
				</xsl:for-each>
			]
		}
	}</script>

	<xsl:if test="count(//entry) &gt; 1">
		<xsl:call-template name="toc"/>
	</xsl:if>

	<xsl:for-each select="//entry">
		<xsl:variable name="entry-name" select="@name"/>
		<xsl:variable name="entry-name-trans" select="translate($entry-name,'$., ()/{}','s---')"/>
		<xsl:variable name="entry-type" select="@type"/>
		<xsl:variable name="entry-index" select="position()"/>
		<xsl:variable name="entry-pos" select="concat($entry-name-trans,$entry-index)"/>
		<xsl:variable name="number-examples" select="count(example)"/>

		<xsl:if test="./added">
			<span class="versionAdded">version added: <xsl:value-of select="added"/></span>
		</xsl:if>

		<article>
			<xsl:attribute name="id">
				<xsl:value-of select="$entry-pos"/>
			</xsl:attribute>
			<xsl:attribute name="class">
				<xsl:value-of select="concat('entry ', $entry-type)"/>
			</xsl:attribute>

			<xsl:call-template name="entry-title"/>
			<xsl:call-template name="entry-body"/>

			<xsl:if test="normalize-space(longdesc/*)">
				<div class="longdesc">
					<xsl:copy-of select="longdesc/*" />
				</div>
			</xsl:if>

			<xsl:if test="note">
				<h3>Additional Notes:</h3>
				<div class="longdesc">
					<ul>
						<xsl:for-each select="note">
							<li><xsl:call-template name="note"/></li>
						</xsl:for-each>
					</ul>
				</div>
			</xsl:if>

			<xsl:if test="example">
				<section class="entry-examples">
					<xsl:attribute name="id">
						<xsl:text>entry-examples</xsl:text>
						<xsl:if test="$entry-index &gt; 1">
							<xsl:text>-</xsl:text><xsl:value-of select="$entry-index - 1"/>
						</xsl:if>
					</xsl:attribute>

					<header>
						<h3 class="underline">Example<xsl:if test="$number-examples &gt; 1">s</xsl:if>:</h3>
					</header>

					<xsl:apply-templates select="example">
						<xsl:with-param name="entry-index" select="$entry-index"/>
						<xsl:with-param name="number-examples" select="$number-examples"/>
					</xsl:apply-templates>
				</section>
			</xsl:if>
		</article>
	</xsl:for-each>
</xsl:template>

<xsl:template name="toc">
	<div class="toc">
		<h4><span>Contents:</span></h4>
		<ul class="toc-list">
			<xsl:for-each select="//entry">
				<xsl:variable name="entry-name-trans" select="translate(@name,'$., ()/{}','s---')" />
				<xsl:variable name="entry-url" select="concat('#',$entry-name-trans,position())"/>
				<xsl:choose>
					<xsl:when test="@type='method'">
						<xsl:call-template name="toc-method">
							<xsl:with-param name="entry-url" select="$entry-url"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="toc-basic">
							<xsl:with-param name="entry-url" select="$entry-url"/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</ul>
	</div>
</xsl:template>

<xsl:template name="toc-basic">
	<xsl:param name="entry-url"/>
	<li><a href="{$entry-url}"><xsl:value-of select="@name"/></a></li>
</xsl:template>

<xsl:template name="toc-method">
	<xsl:param name="entry-url"/>
	<xsl:variable name="entry-name" select="@name"/>

	<li>
		<a href="{$entry-url}">
			<xsl:for-each select="signature[1]">
				<xsl:call-template name="method-signature">
					<xsl:with-param name="method-name" select="$entry-name"/>
				</xsl:call-template>
			</xsl:for-each>
		</a>

		<ul>
			<xsl:for-each select="signature">
				<li>
					<xsl:call-template name="method-signature">
						<xsl:with-param name="method-name" select="$entry-name"/>
					</xsl:call-template>
				</li>
			</xsl:for-each>
		</ul>
	</li>
</xsl:template>

<xsl:template name="method-signature">
	<xsl:param name="method-name"/>

	<xsl:if test="not(contains($method-name, '.')) and $method-name != 'jQuery'">.</xsl:if>
	<xsl:value-of select="$method-name"/>(
	<xsl:if test="argument">
		<xsl:text> </xsl:text>
		<xsl:for-each select="argument">
			<xsl:if test="@optional"> [</xsl:if>
			<xsl:if test="position() &gt; 1"><xsl:text>, </xsl:text></xsl:if>
			<xsl:value-of select="@name"/>
			<xsl:if test="@optional"><xsl:text> ]</xsl:text></xsl:if>
		</xsl:for-each>
		<xsl:text> </xsl:text>
	</xsl:if>)
</xsl:template>

<!-- examples -->
<xsl:template match="example">
	<xsl:param name="entry-index"/>
	<xsl:param name="number-examples"/>

	<div class="entry-example">
		<xsl:attribute name="id">
			<xsl:text>example-</xsl:text>
			<xsl:if test="$entry-index &gt; 1">
				<xsl:value-of select="$entry-index - 1"/>
				<xsl:text>-</xsl:text>
			</xsl:if>
			<xsl:value-of select="position() - 1"/>
		</xsl:attribute>

		<h4>
			<xsl:if test="$number-examples &gt; 1">Example: </xsl:if>
			<span class="desc"><xsl:value-of select="desc"/></span>
		</h4>
		<pre><code data-linenum="true">
			<xsl:choose>
				<xsl:when test="html">
					<xsl:call-template name="example-code"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="code/text()"/>
				</xsl:otherwise>
			</xsl:choose>
		</code></pre>

		<xsl:if test="html">
			<h4>Demo:</h4>
			<div class="demo code-demo">
				<xsl:if test="height">
					<xsl:attribute name="data-height">
						<xsl:value-of select="height"/>
					</xsl:attribute>
				</xsl:if>
			</div>
		</xsl:if>

		<xsl:if test="results">
			<h4>Result:</h4>
			<pre><code class="results">
				<xsl:value-of select="results"/>
			</code></pre>
		</xsl:if>
	</div>
</xsl:template>
<xsl:template name="example-code">
&lt;!DOCTYPE html&gt;
&lt;html&gt;
&lt;head&gt;<xsl:if test="css/text()">
	&lt;style&gt;<xsl:copy-of select="css/text()" />&lt;/style&gt;</xsl:if>
	&lt;script src="http://code.jquery.com/jquery-latest.js"&gt;&lt;/script&gt;<xsl:if test="code/@location='head'">
	&lt;script&gt;
	<xsl:copy-of select="code/text()" />
	&lt;/script&gt;
</xsl:if>
&lt;/head&gt;
&lt;body&gt;
	<xsl:copy-of select="html/text()" />
<xsl:choose>
	<xsl:when test="code/@location='head'"></xsl:when>
	<xsl:otherwise>
&lt;script&gt;<xsl:copy-of select="code/text()" />&lt;/script&gt;</xsl:otherwise>
</xsl:choose>

&lt;/body&gt;
&lt;/html&gt;
</xsl:template>

<xsl:template match="option|property">
		<h5 class="option">
			<xsl:value-of select="@name" />
			<xsl:if test="@added"> <span class="added">(added <xsl:value-of select="@added" />)</span></xsl:if>
			<xsl:if test="@deprecated"> <span class="deprecated">(deprecated <xsl:value-of select="@deprecated" />)</span></xsl:if>
			<xsl:if test="@removed"> <span class="removed">(removed <xsl:value-of select="@removed" />)</span></xsl:if>
			<xsl:text>: </xsl:text>
			<span class="type">
				<xsl:call-template name="render-types" />
			</span>
		</h5>
		<xsl:if test="@default">
			<div class="default-value"><strong>Default: </strong> <xsl:value-of select="@default" /></div>
		</xsl:if>
		<p>
			<xsl:copy-of select="desc/text()|desc/*" />
		</p>
</xsl:template>

<!--
	Render type(s) for an argument element.
	Type can either by a @type attribute or one or more <type> child elements.
-->
<xsl:template name="render-types">
	<xsl:if test="@type and type">
		<strong>ERROR: Use <i>either</i> @type or type elements</strong>
	</xsl:if>

	<!-- a single type -->
	<xsl:if test="@type">
		<xsl:call-template name="render-type">
			<xsl:with-param name="typename" select="@type" />
		</xsl:call-template>
	</xsl:if>

	<!-- elements. Render each type, comma seperated -->
	<xsl:if test="type">
		<xsl:for-each select="type">
			<xsl:if test="position() &gt; 1">, </xsl:if>
			<xsl:call-template name="render-type">
				<xsl:with-param name="typename" select="@name" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template name="render-return-types">
	<xsl:if test="@return and return">
		<strong>ERROR: Use <i>either</i> @return or return element</strong>
	</xsl:if>

	<!-- return attribute -->
	<xsl:if test="@return">
		<xsl:call-template name="render-type">
			<xsl:with-param name="typename" select="@return" />
		</xsl:call-template>
	</xsl:if>

	<!-- a return element -->
	<xsl:if test="return">
		<xsl:for-each select="return">
			<xsl:if test="position() &gt; 1">
				<strong>ERROR: A single return element is expected</strong>
			</xsl:if>
			<xsl:call-template name="render-types" />
		</xsl:for-each>
	</xsl:if>
</xsl:template>

<!-- Render a single type -->
<xsl:template name="render-type">
	<xsl:param name="typename"/>
	<xsl:choose>
	<!--
		If the type is "Function" we special case and write the function signature,
		e.g. function(String)=>String
		- formal arguments are child elements to the current element
		- the return element is optional
	-->
	<xsl:when test="$typename = 'Function'">
		<xsl:text>Function(</xsl:text>
		<xsl:for-each select="argument">
			<xsl:if test="position() &gt; 1">, </xsl:if>
			<xsl:value-of select="@name" />
			<xsl:text>: </xsl:text>
			<xsl:call-template name="render-types" />
		</xsl:for-each>
		<xsl:text>)</xsl:text>

		<!-- display return type if present -->
		<xsl:if test="return or @return">
			=>
			<xsl:call-template name="render-return-types" />
		</xsl:if>
	</xsl:when>
	<xsl:otherwise>
		<!-- not function - just display typename -->
		<a href="http://api.jquery.com/Types#{$typename}"><xsl:value-of select="$typename" /></a>
	</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="entry-title">
	<xsl:param name="entry-type" select="@type"/>
	<xsl:param name="entry-name" select="@name"/>

	<h2 class="jq-clearfix roundTop section-title">
		<xsl:choose>
			<xsl:when test="$entry-type='method'">
				<span class="name">
					<xsl:for-each select="signature[1]">
						<xsl:call-template name="method-signature">
							<xsl:with-param name="method-name" select="$entry-name"/>
						</xsl:call-template>
					</xsl:for-each>
				</span>
				<xsl:text> </xsl:text>
				<span class="returns">
					<xsl:if test="@return != ''">
						<xsl:text>Returns: </xsl:text>
						<a class="return" href="http://api.jquery.com/Types/#{@return}">
							<xsl:value-of select="@return"/>
						</a>
					</xsl:if>
				</span>
			</xsl:when>
			<xsl:when test="$entry-type='selector'">
				<span>
					<xsl:value-of select="@name"/>
					<xsl:text> selector</xsl:text>
				</span>
			</xsl:when>
			<xsl:when test="$entry-type='property'">
				<span>
					<xsl:value-of select="@name"/>
				</span>
				<xsl:text> </xsl:text>
				<span class="returns">
					<xsl:if test="@return != ''">
						<xsl:text>Returns: </xsl:text>
						<a class="return" href="http://api.jquery.com/Types/#{@return}">
							<xsl:value-of select="@return"/>
						</a>
					</xsl:if>
				</span>
			</xsl:when>
		</xsl:choose>
	</h2>
</xsl:template>

<xsl:template name="entry-body">
	<p class="desc"><strong>Description: </strong> <xsl:value-of select="desc"/></p>
	<xsl:choose>
		<xsl:when test="@type='selector'">
			<xsl:call-template name="entry-body-selector"/>
		</xsl:when>
		<xsl:when test="@type='property'">
			<xsl:call-template name="entry-body-property"/>
		</xsl:when>
		<xsl:when test="@type='method'">
			<xsl:call-template name="entry-body-method"/>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="entry-body-selector">
	<ul class="signatures">
		<li class="signature">
			<h4 class="name">
				<xsl:if test="signature/added">
					<span class="versionAdded">
						version added:
						<a href="/category/version/{signature/added}/">
							<xsl:value-of select="signature/added"/>
						</a>
					</span>
				</xsl:if>
				<xsl:text>jQuery( "</xsl:text><xsl:value-of select="sample"/><xsl:text>" )</xsl:text>
			</h4>

			<xsl:for-each select="signature/argument">
				<p class="argument">
					<strong><xsl:value-of select="@name"/>: </strong>
					<xsl:copy-of select="desc/text()|desc/*"/>
				</p>
			</xsl:for-each>
		</li>
	</ul>
</xsl:template>

<xsl:template name="entry-body-property">
	<ul class="signatures">
		<li class="signature">
			<h4 class="name">
				<xsl:if test="signature/added">
					<span class="versionAdded">
						version added:
						<a href="/category/version/{signature/added}/">
							<xsl:value-of select="added"/>
						</a>
					</span>
				</xsl:if>
				<xsl:value-of select="@name"/>
			</h4>
		</li>
	</ul>
</xsl:template>

<xsl:template name="entry-body-method">
	<xsl:variable name="entry-name" select="@name"/>
	<xsl:variable name="entry-name-trans" select="translate($entry-name,'$., ()/{}','s---')"/>

	<ul class="signatures">
		<xsl:for-each select="signature">
			<li class="signature">
				<xsl:attribute name="id">
					<xsl:value-of select="$entry-name-trans"/>
					<xsl:for-each select="argument">
						<xsl:variable name="arg-name" select="translate(@name, ' ,.)(', '--')"/>
						<xsl:text>-</xsl:text><xsl:value-of select="$arg-name"/>
					</xsl:for-each>
				</xsl:attribute>

				<h4 class="name">
					<xsl:if test="./added">
						<span class="versionAdded">
							version added:
							<a href="/category/version/{added}/">
								<xsl:value-of select="added"/>
							</a>
						</span>
					</xsl:if>
					<xsl:call-template name="method-signature">
						<xsl:with-param name="method-name" select="$entry-name"/>
					</xsl:call-template>
				</h4>

				<xsl:for-each select="argument">
					<xsl:variable name="name" select="@name"/>
					<xsl:choose>
						<!-- TODO: get rid of Option -->
						<xsl:when test="@type='Option'">
							<div class="options">
								<xsl:apply-templates select="../../options/option[@name=$name]"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<p class="argument">
								<strong><xsl:value-of select="$name"/>: </strong>
								<xsl:call-template name="render-types"/>
								<xsl:text>
								</xsl:text>
								<xsl:copy-of select="desc/text()|desc/*"/>
							</p>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="option">
						<div class="options">
							<xsl:apply-templates select="option"/>
						</div>
					</xsl:if>
				</xsl:for-each>
			</li>
		</xsl:for-each>
	</ul>
</xsl:template>

<!--
	Notes
	TODO: Move into notes.xsl and pull in via <xsl:import>
-->
<xsl:template name="note">
	<xsl:choose>
		<xsl:when test="@id = 'document-order'">
			Selected elements are in the order of their appearance in the document.
		</xsl:when>
		<xsl:when test="@id = 'domlint'">
			Forms and their child elements should not use input names or ids that conflict with properties of a form, such as <code>submit</code>, <code>length</code>, or <code>method</code>. Name conflicts can cause confusing failures. For a complete list of rules and to check your markup for these problems, see <a href="http://kangax.github.com/domlint/">DOMLint</a>.
		</xsl:when>
		<xsl:when test="@id = 'jquery-selector-extension'">
			Because <code><xsl:value-of select="@data-selector"/></code> is a jQuery extension and not part of the CSS specification, queries using <code><xsl:value-of select="@data-selector"/></code> cannot take advantage of the performance boost provided by the native DOM <code>querySelectorAll()</code> method. To achieve the best performance when using <code><xsl:value-of select="@data-selector"/></code> to select elements, first select the elements using a pure CSS selector, then use <a href="http://api.jquery.com/filter/"><code>.filter("<xsl:value-of select="@data-selector"/>")</code></a>.
		</xsl:when>
		<xsl:when test="@id = 'jquery-selector-extension-alt'">
			Because <code><xsl:value-of select="@data-selector"/></code> is a jQuery extension and not part of the CSS specification, queries using <code><xsl:value-of select="@data-selector"/></code> cannot take advantage of the performance boost provided by the native DOM <code>querySelectorAll()</code> method. For better performance in modern browsers, use <code><xsl:value-of select="@data-alt"/></code> instead.
		</xsl:when>
		<xsl:when test="@id = 'jquery.fx.off'">
			All jQuery effects, including <code><xsl:value-of select="@data-title"/></code>, can be turned off globally by setting <code>jQuery.fx.off = true</code>, which effectively sets the duration to 0. For more information, see <a href="http://api.jquery.com/jquery.fx.off">jQuery.fx.off</a>.
		</xsl:when>
		<xsl:when test="@id = 'no-data-on-xml'">
			Note that this method currently does not provide cross-platform support for setting data on XML documents, as Internet Explorer does not allow data to be attached via expando properties.
		</xsl:when>
		<xsl:when test="@id = 'prop-memory-leaks'">
			In Internet Explorer prior to version 9, using <code><a href="http://api.jquery.com/prop/">.prop()</a></code> to set a DOM element property to anything other than a simple primitive value (number, string, or boolean) can cause memory leaks if the property is not removed (using <a href="http://api.jquery.com/removeProp/"><code>.removeProp()</code></a>) before the DOM element is removed from the document. To safely set values on DOM objects without memory leaks, use <a href="http://api.jquery.com/data/"><code>.data()</code></a>.
		</xsl:when>
		<xsl:when test="@id = 'propagation-for-live-or-delegate'">
			Since the <a href="http://api.jquery.com/live"><code>.live()</code></a> method handles events once they have propagated to the top of the document, it is not possible to stop propagation of live events. Similarly, events handled by <code><a href="http://api.jquery.com/delegate/">.delegate()</a></code> will propagate to the elements to which they are delegated; event handlers bound on any elements below it in the DOM tree will already have been executed by the time the delegated event handler is called. These handlers, therefore, may prevent the delegated handler from triggering by calling <code><a href="http://api.jquery.com/event.stopPropagation/">event.stopPropagation()</a></code> or returning <code>false</code>.
		</xsl:when>
		<xsl:when test="@id = 'same-origin-policy'">
			Due to browser security restrictions, most "Ajax" requests are subject to the <a title="Same Origin Policy on Wikipedia" href="http://en.wikipedia.org/wiki/Same_origin_policy">same origin policy</a>; the request can not successfully retrieve data from a different domain, subdomain, or protocol.
		</xsl:when>
		<xsl:when test="@id = 'same-origin-policy-exceptions'">
			Script and JSONP requests are not subject to the same origin policy restrictions.
		</xsl:when>
		<xsl:when test="@id = 'use-ajaxerror'">
			If a request with <xsl:value-of select="@data-title"/> returns an error code, it will fail silently unless the script has also called the global <a href="http://api.jquery.com/ajaxError/">.ajaxError() </a> method. Alternatively, as of jQuery 1.5, the <code>.error()</code> method of the <code>jqXHR</code> object returned by <xsl:value-of select="@data-title"/> is also available for error handling.
		</xsl:when>
	</xsl:choose>
</xsl:template>

<!-- escape-string, from xml2json.xsl -->
<xsl:template name="escape-string"><xsl:param name="s"/><xsl:text>"</xsl:text><xsl:call-template name="escape-bs-string"><xsl:with-param name="s" select="$s"/></xsl:call-template><xsl:text>"</xsl:text></xsl:template><xsl:template name="escape-bs-string"><xsl:param name="s"/><xsl:choose><xsl:when test="contains($s,'\')"><xsl:call-template name="escape-quot-string"><xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/></xsl:call-template><xsl:call-template name="escape-bs-string"><xsl:with-param name="s" select="substring-after($s,'\')"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="escape-quot-string"><xsl:with-param name="s" select="$s"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:template><xsl:template name="escape-quot-string"><xsl:param name="s"/><xsl:choose><xsl:when test="contains($s,'&quot;')"><xsl:call-template name="encode-string"><xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/></xsl:call-template><xsl:call-template name="escape-quot-string"><xsl:with-param name="s" select="substring-after($s,'&quot;')"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:call-template name="encode-string"><xsl:with-param name="s" select="$s"/></xsl:call-template></xsl:otherwise></xsl:choose></xsl:template><xsl:template name="encode-string"><xsl:param name="s"/><xsl:choose><!-- tab --><xsl:when test="contains($s,'&#x9;')"><xsl:call-template name="encode-string"><xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'\t',substring-after($s,'&#x9;'))"/></xsl:call-template></xsl:when><!-- line feed --><xsl:when test="contains($s,'&#xA;')"><xsl:call-template name="encode-string"><xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'\n',substring-after($s,'&#xA;'))"/></xsl:call-template></xsl:when><!-- carriage return --><xsl:when test="contains($s,'&#xD;')"><xsl:call-template name="encode-string"><xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'\r',substring-after($s,'&#xD;'))"/></xsl:call-template></xsl:when><xsl:otherwise><xsl:value-of select="$s"/></xsl:otherwise></xsl:choose></xsl:template>

</xsl:stylesheet>
