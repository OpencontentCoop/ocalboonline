<p>
    {if $current_user.is_logged_in}

        {if fetch( 'user', 'has_access_to', hash( 'module', 'user', 'function', 'selfedit' ) )}
            <span class="u-margin-right-s" id="myprofile">
                <a href={"/user/edit/"|ezurl} title="Visualizza il profilo utente">Profilo utente</a>
            </span>
        {/if}

        {if fetch( 'user', 'has_access_to', hash( 'module', 'content', 'function', 'dashboard' ) )}
            <span class="u-margin-right-s">
                <a href="{"/content/dashboard/"|ezurl(no)}"
                   title="Pannello strumenti">Strumenti</a>
            </span>
        {/if}

        {if fetch( 'user', 'has_access_to', hash( 'module', 'alboonline', 'function', 'dashboard' ) )}
            <span class="u-margin-right-s">
                <a href="{"/alboonline/dashboard/"|ezurl(no)}"
                   title="Cruscotto Albo">Cruscotto Albo</a>
            </span>
        {/if}

        <span class="u-margin-right-s" id="logout">
            <a href="{"/user/logout"|ezurl(no)}" title="Esegui il logout">
                Logout {*({$current_user.contentobject.name|wash})*}
            </a>
        </span>
    {else}

        {if ezmodule( 'user/login' )}
            <span class="u-margin-right-s" id="login">
                <a href="{concat("/user/login?url=",$module_result.uri)|ezurl(no)}"
                   title="Esegui il login al sito">Accedi con il tuo account</a>
            </span>
        {/if}

        {if ezmodule( 'user/register' )}
            <span class="u-margin-right-s" id="registeruser">
                <a href="{"/user/register"|ezurl(no)}" title="Registrati al sito">
                    Crea il tuo account</a>
            </span>
        {/if}

    {/if}
</p>
