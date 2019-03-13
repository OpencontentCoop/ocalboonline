<p>

    <span class="u-margin-right-s" id="login" style="display: none;">
        <a href="{"/user/login"|ezurl(no)}"
           title="Esegui il login al sito">Accedi con il tuo account</a>
    </span>

    {if and(ezmodule( 'user/register' ), fetch( 'user', 'has_access_to', hash( 'module', 'user', 'function', 'register' ) ))}
        <span class="u-margin-right-s" id="registeruser" style="display: none;">
            <a href="{"/user/register"|ezurl(no)}"
               title="Registrati al sito"> Crea il tuo account</a>
        </span>
    {/if}

</p>

<script>{literal}
    $(document).ready(function(){
        var login = $('#login');
        login.find('a').attr('href', login.find('a').attr('href') + '?url='+ ModuleResultUri);
        var register = $('#registeruser');
        login.attr('href', login.attr('href') + '?url='+ ModuleResultUri);
        var injectUserInfo = function(data){
            if(data.error_text || !data.content){
                login.show();
                register.show();
            }else{
                login.after('<span class="u-margin-right-s" id="myprofile"><a href="/user/edit/" title="Visualizza il profilo utente">Il mio profilo</a></span><span class="u-margin-right-s" id="logout"><a href="/user/logout" title="Logout">Logout ('+data.content.name+')</a></span>');
                if(data.content.has_access_to_dashboard){
                    login.after('<span class="u-margin-right-s"><a href="/content/dashboard/" title="Pannello strumenti">Pannello strumenti</a></span><span class="u-margin-right-s"><a href="/alboonline/dashboard/" title="Cruscotto Albo">Cruscotto Albo</a></span>');
                }
                login.remove();
                register.remove();
            }
        };
        if(CurrentUserIsLoggedIn){
            $.ez('openpaajax::userInfo', null, function(data){
                injectUserInfo(data);
            });
        }else{
            login.show();
            register.show();
        }
    });
{/literal}</script>
